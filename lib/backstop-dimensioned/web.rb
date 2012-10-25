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

  def measurements(request)
    JSON.parse(request.body.read)
  end
end

module Backstop
  module Dimensioned
    class Web < Sinatra::Base

      helpers PublisherHelper
      helpers Backstop::Dimensioned::Log

      post '/publish/custom/dimensioned' do
        publish(measurements(request))

        {}.to_json
      end
    end
  end
end
