require 'spec_helper'
require 'rack/test'

describe Backstop::Dimensioned::Web do
  include Rack::Test::Methods

  def app
    Backstop::Dimensioned::Web
  end

  after do
    begin
      File.open("#{APP_ROOT}/spec/last_response.html", 'w+'){|f| f.write(last_response.body) }
    rescue
    end
  end

  describe 'POST /publish/custom/dimensioned' do
    context "multi measured sample" do
      let(:measure_time) { Time.now.to_i }
      let(:data) do
        [
         {
           :metric => "latency",
           :count => 10,
           :sum => 100,
           :min => 10,
           :max => 11,
           :measure_time => measure_time,
           :period => 60,
           :dimensions => %w[test elb123 us-east-1a]
         }
        ]
      end

      it('should return a 200') do
        post "/publish/custom/dimensioned", data.to_json
        last_response.should be_ok
      end

      it "should submit the correct data to graphite" do
        app.any_instance.should_receive(:submit_to_graphite).with("test.elb123.us-east-1a.latency.count", 10, measure_time, 60)
        app.any_instance.should_receive(:submit_to_graphite).with("test.elb123.us-east-1a.latency.sum", 100, measure_time, 60)
        app.any_instance.should_receive(:submit_to_graphite).with("test.elb123.us-east-1a.latency.min", 10, measure_time, 60)
        app.any_instance.should_receive(:submit_to_graphite).with("test.elb123.us-east-1a.latency.max", 11, measure_time, 60)

        post "/publish/custom/dimensioned", data.to_json
      end

      it "should submit the correct data to librato" do
        app.any_instance.should_receive(:submit_to_librato).with(
                                                                 "latency",
                                                                 {
                                                                   "count" => 10,
                                                                   "sum" => 100,
                                                                   "min" => 10,
                                                                   "max" => 11
                                                                 },
                                                                 "test.elb123.us-east-1a",
                                                                 measure_time,
                                                                 60)
        post "/publish/custom/dimensioned", data.to_json
      end
    end

    context "single measured sample" do
    end
  end

end
