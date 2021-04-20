require "rails_helper"

RSpec.describe InPreProdLotStocksController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/in_pre_prod_lot_stocks").to route_to("in_pre_prod_lot_stocks#index")
    end

    it "routes to #new" do
      expect(:get => "/in_pre_prod_lot_stocks/new").to route_to("in_pre_prod_lot_stocks#new")
    end

    it "routes to #show" do
      expect(:get => "/in_pre_prod_lot_stocks/1").to route_to("in_pre_prod_lot_stocks#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/in_pre_prod_lot_stocks/1/edit").to route_to("in_pre_prod_lot_stocks#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/in_pre_prod_lot_stocks").to route_to("in_pre_prod_lot_stocks#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/in_pre_prod_lot_stocks/1").to route_to("in_pre_prod_lot_stocks#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/in_pre_prod_lot_stocks/1").to route_to("in_pre_prod_lot_stocks#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/in_pre_prod_lot_stocks/1").to route_to("in_pre_prod_lot_stocks#destroy", :id => "1")
    end
  end
end
