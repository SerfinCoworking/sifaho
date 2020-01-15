require 'rails_helper'

RSpec.describe "Lots", type: :request do
  describe "GET /lots" do
    it "works! (now write some real specs)" do
      get lots_path
      expect(response).to have_http_status(200)
    end
  end
end
