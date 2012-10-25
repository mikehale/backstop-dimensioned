require 'spec_helper'

describe Backstop::Publisher::Librato do
  subject { Backstop::Publisher::Librato.new }

  before do
    subject.stub(:send_to_librato)
  end

  let(:measure_time) { Time.now.to_i }
  let(:measurment) {
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
  let(:stale_measurement) {
    Timecop.travel(Time.now - 60*60*2) do
      measurment.merge("measure_time" => Time.now.to_i)
    end
  }

  describe :publish do
    it "should send the measurment" do
      subject.should_receive(:send_to_librato).with(
                                                    "foo" => {
                                                      :period => 60,
                                                      :measure_time => measure_time,
                                                      :sum => 100,
                                                      :min => 8,
                                                      :max => 12,
                                                      :count => 10,
                                                      :source => "test.joe.bob"
                                                    })
      subject.publish(measurment)
    end

    it "should not submit old measurments" do
      subject.should_not_receive(:send_to_librato)
      lambda { subject.publish(stale_measurement) }.should raise_error Backstop::Publisher::Librato::MetricTooOldError
    end
  end
end
