module Backstop
  module Publisher

    class Graphite
      def publish(m)
        raise "graphite#submit"
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
    end

  end
end
