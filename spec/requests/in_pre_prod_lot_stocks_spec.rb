require 'rails_helper'

RSpec.describe "InPreProdLotStocks", type: :request do
  describe "GET /in_pre_prod_lot_stocks" do
    it "works! (now write some real specs)" do
      get in_pre_prod_lot_stocks_path
      expect(response).to have_http_status(200)
    end
  end
end
