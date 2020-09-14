require "rails_helper"

RSpec.describe PatientProductReportsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/patient_product_reports").to route_to("patient_product_reports#index")
    end

    it "routes to #new" do
      expect(:get => "/patient_product_reports/new").to route_to("patient_product_reports#new")
    end

    it "routes to #show" do
      expect(:get => "/patient_product_reports/1").to route_to("patient_product_reports#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/patient_product_reports/1/edit").to route_to("patient_product_reports#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/patient_product_reports").to route_to("patient_product_reports#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/patient_product_reports/1").to route_to("patient_product_reports#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/patient_product_reports/1").to route_to("patient_product_reports#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/patient_product_reports/1").to route_to("patient_product_reports#destroy", :id => "1")
    end
  end
end
