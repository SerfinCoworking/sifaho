require 'rails_helper'

RSpec.describe "InpatientPrescriptionProducts", type: :request do
  describe "GET /inpatient_prescription_products" do
    it "works! (now write some real specs)" do
      get inpatient_prescription_products_path
      expect(response).to have_http_status(200)
    end
  end
end
