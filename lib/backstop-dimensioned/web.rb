require 'json'

module Backstop
  module Dimensioned
    class Web < Sinatra::Base

      helpers do
        def submit_to_graphite(name, value, measure_time, period)
        end

        def submit_to_librato(name, value, source, measure_time, period)

        end

        def submit(measurements)
          measurements.each do |m|
            dimensions = m["dimensions"] || []
            name = m["metric"]
            period = m["period"]
            measure_time = m["measure_time"]
            
            %w[sum min max count].each do |value_name|
              if value = m[value_name]
                submit_to_graphite("#{[dimensions, name].join(".")}.#{value_name}", value, measure_time, period)
              end
            end


            value = Hash[%w[sum min max count].map do |value_name|
                           [value_name, m[value_name]]
                         end]
            submit_to_librato(name, value, dimensions.join("."), measure_time, period)
          end

        end
      end

      post '/publish/custom/dimensioned' do
        measurements = JSON.parse(request.body.read)
        submit(measurements)
        {}.to_json
      end
    end
  end
end
