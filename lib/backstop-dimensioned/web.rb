require 'json'

module Librato
  class MetricTooOldError < RuntimeError
  end
end

module Backstop
  module Dimensioned
    class Web < Sinatra::Base

      helpers do
        def log(data, &blk)
          Scrolls.log(data.merge(:app => 'backstop-dimensioned', :ps => 'web'), &blk)
        end
        
        def queue
          @@queue ||= Librato::Metrics::Queue.new(:autosubmit_interval => 60, :autosubmit_count => 400)
        end

        def submit_to_graphite(m)
          dimensions = m["dimensions"] || []
          name = m["metric"]
          period = m["period"]
          measure_time = m["measure_time"]

          %w[sum min max count].each do |value_name|
            if value = m[value_name]
              #submit_to_graphite("#{[dimensions, name].join(".")}.#{value_name}", value, measure_time, period)
            end
          end
        end

        def submit_to_librato(m)
          dimensions = m["dimensions"] || []
          name = m["metric"]
          period = m["period"]
          measure_time = m["measure_time"]

          value = Hash[%w[sum min max count].map do |value_name|
                         [value_name, m[value_name]]
                       end]

          source = if dimensions
                     {:source => dimensions.join(".")}
                   else
                     {}
                   end


          begin
            if Time.at(measure_time.to_i) <= (Time.now - 7140)
              raise Librato::MetricTooOldError
            else
              queue.add(name => { :period => period, :measure_time => measure_time }.merge(value).merge(source) )
            end
          rescue => e
            log(:fn => 'submit_to_librato', :at => 'error', :exception => e.class.name, :metric => name, :value => value.inspect, :measure_time => measure_time)
          end
        end

        def submit(measurements)
          measurements.each do |m|
            submit_to_graphite(m)
            submit_to_librato(m)
          end
        end

        def measurements(request)
          JSON.parse(request.body.read)
        end

      end

      post '/publish/custom/dimensioned' do
        submit(measurements(request))

        {}.to_json
      end
    end
  end
end
