require 'rails_helper'

RSpec.describe "InpatientMovements", type: :request do
  describe "GET /inpatient_movements" do
    it "works! (now write some real specs)" do
      get inpatient_movements_path
      expect(response).to have_http_status(200)
    end
  end
end
