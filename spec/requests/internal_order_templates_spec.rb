require 'rails_helper'

RSpec.describe "InternalOrderTemplates", type: :request do
  describe "GET /internal_order_templates" do
    it "works! (now write some real specs)" do
      get internal_order_templates_path
      expect(response).to have_http_status(200)
    end
  end
end
