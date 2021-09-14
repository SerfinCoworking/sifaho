require "rails_helper"

RSpec.describe UnifyProductsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/unify_products").to route_to("unify_products#index")
    end

    it "routes to #new" do
      expect(:get => "/unify_products/new").to route_to("unify_products#new")
    end

    it "routes to #show" do
      expect(:get => "/unify_products/1").to route_to("unify_products#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/unify_products/1/edit").to route_to("unify_products#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/unify_products").to route_to("unify_products#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/unify_products/1").to route_to("unify_products#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/unify_products/1").to route_to("unify_products#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/unify_products/1").to route_to("unify_products#destroy", :id => "1")
    end
  end
end
