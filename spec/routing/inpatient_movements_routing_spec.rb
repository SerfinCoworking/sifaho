require "rails_helper"

RSpec.describe InpatientMovementsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/inpatient_movements").to route_to("inpatient_movements#index")
    end

    it "routes to #new" do
      expect(:get => "/inpatient_movements/new").to route_to("inpatient_movements#new")
    end

    it "routes to #show" do
      expect(:get => "/inpatient_movements/1").to route_to("inpatient_movements#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/inpatient_movements/1/edit").to route_to("inpatient_movements#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/inpatient_movements").to route_to("inpatient_movements#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/inpatient_movements/1").to route_to("inpatient_movements#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/inpatient_movements/1").to route_to("inpatient_movements#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/inpatient_movements/1").to route_to("inpatient_movements#destroy", :id => "1")
    end
  end
end
