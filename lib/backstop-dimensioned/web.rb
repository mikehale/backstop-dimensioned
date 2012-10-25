require 'json'

module PublisherHelper
  def publish(measurements)
    measurements.each do |m|
      librato.publish(m)
      #graphite.publish(m)
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

      helpers do
        def log(data, &blk)
          Scrolls.log(data.merge(:app => 'backstop-dimensioned', :ps => 'web'), &blk)
        end
      end

      post '/publish/custom/dimensioned' do
        publish(measurements(request))

        {}.to_json
      end
    end
  end
end
