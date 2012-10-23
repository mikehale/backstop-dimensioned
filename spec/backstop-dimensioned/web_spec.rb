require 'spec_helper'
require 'rack/test'

describe Backstop::Dimensioned::Web do
  include Rack::Test::Methods

  def app
    Backstop::Dimensioned::Web
  end

  describe 'POST /publish/custom/dimensioned' do
    it('should return a 200') do
      post "/publish/custom/dimensioned", {}
      last_response.status.should eq(200)
    end
  end

end
