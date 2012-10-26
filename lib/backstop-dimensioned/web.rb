require 'json'

module PublisherHelper
  def publish(measurements)
    log(step: :publish) do
      measurements.each do |m|
        librato.publish(m)
        #graphite.publish(m)
      end
    end
  end

  def librato
    @@librato ||= Backstop::Publisher::Librato.new
  end

  def graphite
    @@graphite ||= Backstop::Publisher::Graphite.new
  end

  def error(code, message, data=nil)
    response = { :message => message }
    response[:data] = data if data

    halt(code, response.to_json)
  end

  def multi_sample?(m)
    %w[sum min max count].all? {|value_key| m.has_key?(value_key) }
  end

  def single_sample?(m)
    m.has_key?("value")
  end

  def validate!(data)
    unless data.is_a?(Array) and data.all? {|e| e.is_a? Hash }
      error(422, "An array of measurements is expected", data)
    end

    data.each do |m|
      unless m.has_key?("measure_time")
        error(422, "Measurements must have a measure_time", m)
      end

      unless m.has_key?("metric")
        error(422, "Measurements must have a metric", m)
      end

      if m.has_key?("dimensions")
        unless m["dimensions"].is_a?(Array) and m["dimensions"].all?{|e| e.is_a?(String) }
          error(422, "Dimensions must be an array of strings", m)
        end
      end

      if (multi_sample?(m) and single_sample?(m)) or (!multi_sample?(m) and !single_sample?(m))
        error(422, "Must include: sum, min, max, count OR value", m)
      end
    end
  end

  def measurements(request)
    data = JSON.parse(request.body.read)
    validate!(data)
    data
  rescue JSON::ParserError
    error(400, "JSON is required")
  end
end

module Backstop
  module Dimensioned
    class Web < Sinatra::Base

      helpers PublisherHelper
      helpers Backstop::Dimensioned::Log

      post '/publish/custom/dimensioned' do
        publish(measurements(request))

        { :message => "OK" }.to_json
      end
    end
  end
end
