require 'rails_helper'

RSpec.describe "in_pre_prod_lot_stocks/show", type: :view do
  before(:each) do
    @in_pre_prod_lot_stock = assign(:in_pre_prod_lot_stock, InPreProdLotStock.create!(
      :inpatient_prescription_product => nil,
      :lot_stock => nil,
      :dispensed_by => nil,
      :quantity => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
  end
end
