require "rails_helper"

RSpec.describe InpatientPrescriptionProductsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/inpatient_prescription_products").to route_to("inpatient_prescription_products#index")
    end

    it "routes to #new" do
      expect(:get => "/inpatient_prescription_products/new").to route_to("inpatient_prescription_products#new")
    end

    it "routes to #show" do
      expect(:get => "/inpatient_prescription_products/1").to route_to("inpatient_prescription_products#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/inpatient_prescription_products/1/edit").to route_to("inpatient_prescription_products#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/inpatient_prescription_products").to route_to("inpatient_prescription_products#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/inpatient_prescription_products/1").to route_to("inpatient_prescription_products#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/inpatient_prescription_products/1").to route_to("inpatient_prescription_products#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/inpatient_prescription_products/1").to route_to("inpatient_prescription_products#destroy", :id => "1")
    end
  end
end
