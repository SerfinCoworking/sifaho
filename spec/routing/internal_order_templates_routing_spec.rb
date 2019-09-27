require "rails_helper"

RSpec.describe InternalOrderTemplatesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/internal_order_templates").to route_to("internal_order_templates#index")
    end

    it "routes to #new" do
      expect(:get => "/internal_order_templates/new").to route_to("internal_order_templates#new")
    end

    it "routes to #show" do
      expect(:get => "/internal_order_templates/1").to route_to("internal_order_templates#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/internal_order_templates/1/edit").to route_to("internal_order_templates#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/internal_order_templates").to route_to("internal_order_templates#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/internal_order_templates/1").to route_to("internal_order_templates#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/internal_order_templates/1").to route_to("internal_order_templates#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/internal_order_templates/1").to route_to("internal_order_templates#destroy", :id => "1")
    end
  end
end
