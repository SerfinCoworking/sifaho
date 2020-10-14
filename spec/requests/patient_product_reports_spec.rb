require 'rails_helper'

RSpec.describe "PatientProductReports", type: :request do
  describe "GET /patient_product_reports" do
    it "works! (now write some real specs)" do
      get patient_product_reports_path
      expect(response).to have_http_status(200)
    end
  end
end
