require 'rails_helper'

RSpec.describe "UnifyProducts", type: :request do
  describe "GET /unify_products" do
    it "works! (now write some real specs)" do
      get unify_products_path
      expect(response).to have_http_status(200)
    end
  end
end
