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
    let(:data) do
      [{"a" => 1}]
    end

    let(:non_json_data) do
      "not json"
    end

    it('should return a 200') do
      app.any_instance.stub(:publish)
      app.any_instance.stub(:validate!)
      post "/publish/custom/dimensioned", data.to_json
      last_response.should be_ok
      JSON.parse(last_response.body)["message"].should == "OK"
    end

    it "should handle non-json data" do
      app.any_instance.stub(:publish)
      post "/publish/custom/dimensioned", non_json_data
      last_response.status.should == 400
      JSON.parse(last_response.body)["message"].should == "JSON is required"
    end

    it "should submit the measurements to the publishers" do
      app.any_instance.stub(:validate!)
      Backstop::Publisher::Librato.any_instance.should_receive(:publish).with(data.first)
      # Backstop::Publisher::Graphite.any_instance.should_receive(:publish).with(data.first)
      post "/publish/custom/dimensioned", data.to_json
    end

    context "validations" do
      let(:measurement) {
        {
          "metric" => "foo",
          "period" => 60,
          "measure_time" => 1234567890,
          "dimensions" => %w[test joe bob],
          "sum" => 100,
          "min" => 8,
          "max" => 12,
          "count" => 10
        }
      }

      it "should validate that an array of measurements are sent" do
        app.any_instance.stub(:publish)
        post "/publish/custom/dimensioned", {}.to_json
        last_response.status.should == 422
        JSON.parse(last_response.body)["message"].should == "An array of measurements is expected"

        app.any_instance.stub(:publish)
        post "/publish/custom/dimensioned", [1].to_json
        last_response.status.should == 422
        JSON.parse(last_response.body)["message"].should == "An array of measurements is expected"
      end

      it "should validate that each measurement has a measure_time" do
        app.any_instance.stub(:publish)
        post "/publish/custom/dimensioned", [measurement.reject{|k,v| k == "measure_time" }].to_json
        last_response.status.should == 422
        JSON.parse(last_response.body)["message"].should include "Measurements must have a measure_time"
      end

      it "should validate that each measurement has a metric" do
        app.any_instance.stub(:publish)
        post "/publish/custom/dimensioned", [measurement.reject{|k,v| k == "metric" }].to_json
        last_response.status.should == 422
        JSON.parse(last_response.body)["message"].should include "Measurements must have a metric"
      end

      it "should validate that dimensions is an array of strings" do
        measurement["dimensions"] = 1
        app.any_instance.stub(:publish)
        post "/publish/custom/dimensioned", [measurement].to_json
        last_response.status.should == 422
        JSON.parse(last_response.body)["message"].should include "Dimensions must be an array of strings"

        measurement["dimensions"] = [{}]
        app.any_instance.stub(:publish)
        post "/publish/custom/dimensioned", [measurement].to_json
        last_response.status.should == 422
        JSON.parse(last_response.body)["message"].should include "Dimensions must be an array of strings"
      end

      it "should validate that each measurement is multi or single sample" do
        measurement["value"] = 1
        app.any_instance.stub(:publish)
        post "/publish/custom/dimensioned", [measurement].to_json
        last_response.status.should == 422
        JSON.parse(last_response.body)["message"].should include "Must include: sum, min, max, count OR value"

        app.any_instance.stub(:publish)
        post "/publish/custom/dimensioned", [measurement.reject{|k,v| %w[value sum min max count].include?(k) }].to_json
        last_response.status.should == 422
        JSON.parse(last_response.body)["message"].should include "Must include: sum, min, max, count OR value"
      end

    end

  end

end
