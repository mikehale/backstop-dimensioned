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
        [{"a" => 1}]
      end

      it('should return a 200') do
        app.any_instance.stub(:publish)
        post "/publish/custom/dimensioned", data.to_json
        last_response.should be_ok
      end

      it "should submit the measurments to the publishers" do
        Backstop::Publisher::Librato.any_instance.should_receive(:publish).with(data.first)
        # Backstop::Publisher::Graphite.any_instance.should_receive(:publish).with(data.first)
        post "/publish/custom/dimensioned", data.to_json
      end
    end
  end

end
