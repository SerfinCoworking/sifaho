require "rails_helper"

RSpec.describe LotsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/lots").to route_to("lots#index")
    end

    it "routes to #new" do
      expect(:get => "/lots/new").to route_to("lots#new")
    end

    it "routes to #show" do
      expect(:get => "/lots/1").to route_to("lots#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/lots/1/edit").to route_to("lots#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/lots").to route_to("lots#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/lots/1").to route_to("lots#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/lots/1").to route_to("lots#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/lots/1").to route_to("lots#destroy", :id => "1")
    end
  end
end
