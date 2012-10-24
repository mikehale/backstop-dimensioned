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
        [{}]
      end

      it('should return a 200') do
        post "/publish/custom/dimensioned", data.to_json
        last_response.should be_ok
      end

      it "should submit the correct data to graphite" do
        app.any_instance.should_receive(:submit_to_graphite).with(data.first)
        post "/publish/custom/dimensioned", data.to_json
      end

      it "should submit the correct data to librato" do
        app.any_instance.should_receive(:submit_to_librato).with(data.first)
        post "/publish/custom/dimensioned", data.to_json
      end
    end
  end

end
