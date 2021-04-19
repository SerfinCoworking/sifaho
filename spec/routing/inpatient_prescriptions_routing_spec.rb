require "rails_helper"

RSpec.describe InpatientPrescriptionsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/inpatient_prescriptions").to route_to("inpatient_prescriptions#index")
    end

    it "routes to #new" do
      expect(:get => "/inpatient_prescriptions/new").to route_to("inpatient_prescriptions#new")
    end

    it "routes to #show" do
      expect(:get => "/inpatient_prescriptions/1").to route_to("inpatient_prescriptions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/inpatient_prescriptions/1/edit").to route_to("inpatient_prescriptions#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/inpatient_prescriptions").to route_to("inpatient_prescriptions#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/inpatient_prescriptions/1").to route_to("inpatient_prescriptions#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/inpatient_prescriptions/1").to route_to("inpatient_prescriptions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/inpatient_prescriptions/1").to route_to("inpatient_prescriptions#destroy", :id => "1")
    end
  end
end
