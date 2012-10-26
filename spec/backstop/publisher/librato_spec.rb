require 'spec_helper'

describe Backstop::Publisher::Librato do
  subject { Backstop::Publisher::Librato.new }


  it "should authenticate from the LIBRATO_URI" do
    ENV["LIBRATO_URI"] = "https://user%40example.com:pass@metrics-api.librato.com/v1/metrics"
    Librato::Metrics.should_receive(:authenticate).with("user@example.com", "pass")
    subject.auth
  end

  describe :publish do
    before do
      subject.stub(:auth)
    end

    let(:stale_measurement) {
      Timecop.travel(Time.now - 60*60*2) do
        { "measure_time" => Time.now.to_i }
      end
    }

    it "should not queue old measurements" do
      subject.queue.should_not_receive(:add)
      lambda { subject.publish(stale_measurement) }.should raise_error Backstop::Publisher::Librato::MetricTooOldError
    end

    context "multi measured sample" do
      let(:measure_time) { Time.now.to_i }
      let(:measurement) {
        {
          "metric" => "foo",
          "period" => 60,
          "measure_time" => measure_time,
          "dimensions" => %w[test joe bob],
          "sum" => 100,
          "min" => 8,
          "max" => 12,
          "count" => 10
        }
      }

      it "should queue the measurement" do
        subject.queue.should_receive(:add).with(
                                                "foo" => {
                                                  :period => 60,
                                                  :measure_time => measure_time,
                                                  :sum => 100,
                                                  :min => 8,
                                                  :max => 12,
                                                  :count => 10,
                                                  :source => "test.joe.bob"
                                                })
        subject.publish(measurement)
      end
    end

    context "single measured sample" do
      let(:measure_time) { Time.now.to_i }
      let(:measurement) {
        {
          "metric" => "foo",
          "period" => 60,
          "measure_time" => measure_time,
          "dimensions" => %w[test joe bob],
          "value" => 10
        }
      }
      it "should queue the measurement" do
        subject.queue.should_receive(:add).with(
                                                "foo" => {
                                                  :period => 60,
                                                  :measure_time => measure_time,
                                                  :value => 10,
                                                  :source => "test.joe.bob"
                                                })
        subject.publish(measurement)
      end
    end

  end
end
