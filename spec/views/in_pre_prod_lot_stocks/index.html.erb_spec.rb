require 'rails_helper'

RSpec.describe "in_pre_prod_lot_stocks/index", type: :view do
  before(:each) do
    assign(:in_pre_prod_lot_stocks, [
      InPreProdLotStock.create!(
        :inpatient_prescription_product => nil,
        :lot_stock => nil,
        :dispensed_by => nil,
        :quantity => 2
      ),
      InPreProdLotStock.create!(
        :inpatient_prescription_product => nil,
        :lot_stock => nil,
        :dispensed_by => nil,
        :quantity => 2
      )
    ])
  end

  it "renders a list of in_pre_prod_lot_stocks" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
