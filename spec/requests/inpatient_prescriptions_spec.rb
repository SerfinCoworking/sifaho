require 'rails_helper'

RSpec.describe "InpatientPrescriptions", type: :request do
  describe "GET /inpatient_prescriptions" do
    it "works! (now write some real specs)" do
      get inpatient_prescriptions_path
      expect(response).to have_http_status(200)
    end
  end
end
