require 'rails_helper'

RSpec.describe "in_pre_prod_lot_stocks/edit", type: :view do
  before(:each) do
    @in_pre_prod_lot_stock = assign(:in_pre_prod_lot_stock, InPreProdLotStock.create!(
      :inpatient_prescription_product => nil,
      :lot_stock => nil,
      :dispensed_by => nil,
      :quantity => 1
    ))
  end

  it "renders the edit in_pre_prod_lot_stock form" do
    render

    assert_select "form[action=?][method=?]", in_pre_prod_lot_stock_path(@in_pre_prod_lot_stock), "post" do

      assert_select "input[name=?]", "in_pre_prod_lot_stock[inpatient_prescription_product_id]"

      assert_select "input[name=?]", "in_pre_prod_lot_stock[lot_stock_id]"

      assert_select "input[name=?]", "in_pre_prod_lot_stock[dispensed_by_id]"

      assert_select "input[name=?]", "in_pre_prod_lot_stock[quantity]"
    end
  end
end
