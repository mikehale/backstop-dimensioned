require 'librato/metrics'

module Backstop
  module Publisher

    class Librato
      class MetricTooOldError < RuntimeError; end
      include Backstop::Dimensioned::Log

      def auth
        ::Librato::Metrics.authenticate(Backstop::Config.librato_uri.user.gsub('%40', '@'), Backstop::Config.librato_uri.password)
      end

      def queue
        unless @queue
          auth
          @queue = ::Librato::Metrics::Queue.new(:autosubmit_interval => 1, :autosubmit_count => 1)
        end

        @queue
      end

      def source(m)
        dimensions = m["dimensions"] || []

        if dimensions.size > 0
          {:source => dimensions.join(".")}
        else
          {}
        end
      end

      def single_measurement?(m)
        m.has_key?("value")
      end

      def value(m)
        if single_measurement?(m)
          { :value => m["value"] }
        else
          Hash[
               %w[sum min max count].map do |value_name|
                 [value_name.to_sym, m[value_name]]
               end
              ]
        end
      end

      def publish(m)
        name = m["metric"]
        period = m["period"]
        measure_time = m["measure_time"]

        value = value(m)
        source = source(m)

        data = { name => { :period => period, :measure_time => measure_time }.merge(value).merge(source) }
        if Time.at(measure_time.to_i) > (Time.now - 7140)
          log(step: :queue, data: data)
          queue.add(data)
        else
          raise MetricTooOldError
        end
      end
    end

  end
end
