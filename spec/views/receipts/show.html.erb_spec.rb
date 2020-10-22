require 'rails_helper'

RSpec.describe "receipts/show", type: :view do
  before(:each) do
    @receipt = assign(:receipt, Receipt.create!(
      :supply => nil,
      :supply_lot => nil,
      :lot_code => "Lot Code",
      :laboratory_name => "Laboratory Name",
      :quantity => 2,
      :code => "Code"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Lot Code/)
    expect(rendered).to match(/Laboratory Name/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Code/)
  end
end
