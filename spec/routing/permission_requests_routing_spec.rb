require "rails_helper"

RSpec.describe PermissionRequestsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/permission_requests").to route_to("permission_requests#index")
    end

    it "routes to #new" do
      expect(:get => "/permission_requests/new").to route_to("permission_requests#new")
    end

    it "routes to #show" do
      expect(:get => "/permission_requests/1").to route_to("permission_requests#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/permission_requests/1/edit").to route_to("permission_requests#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/permission_requests").to route_to("permission_requests#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/permission_requests/1").to route_to("permission_requests#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/permission_requests/1").to route_to("permission_requests#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/permission_requests/1").to route_to("permission_requests#destroy", :id => "1")
    end
  end
end
