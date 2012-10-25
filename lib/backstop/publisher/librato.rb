module Backstop
  module Publisher

    class Librato
      class MetricTooOldError < RuntimeError; end

      def queue
        @@queue ||= Librato::Metrics::Queue.new(:autosubmit_interval => 60, :autosubmit_count => 400)
      end

      def source(m)
        dimensions = m["dimensions"] || []

        if dimensions.size > 0
          {:source => dimensions.join(".")}
        else
          {}
        end
      end

      def value(m)
        Hash[
             %w[sum min max count].map do |value_name|
               [value_name.to_sym, m[value_name]]
             end
            ]
      end

      def send_to_librato(*args)
        queue.add(*args)
      end

      def publish(m)
        name = m["metric"]
        period = m["period"]
        measure_time = m["measure_time"]

        value = value(m)
        source = source(m)

        if Time.at(measure_time.to_i) > (Time.now - 7140)
          send_to_librato(name => { :period => period, :measure_time => measure_time }.merge(value).merge(source))
        else
          raise MetricTooOldError
        end
      end
    end

  end
end
