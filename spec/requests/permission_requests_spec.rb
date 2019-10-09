require 'rails_helper'

RSpec.describe "PermissionRequests", type: :request do
  describe "GET /permission_requests" do
    it "works! (now write some real specs)" do
      get permission_requests_path
      expect(response).to have_http_status(200)
    end
  end
end
