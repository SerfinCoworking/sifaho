require 'rails_helper'

RSpec.describe "receipts/index", type: :view do
  before(:each) do
    assign(:receipts, [
      Receipt.create!(
        :supply => nil,
        :supply_lot => nil,
        :lot_code => "Lot Code",
        :laboratory_name => "Laboratory Name",
        :quantity => 2,
        :code => "Code"
      ),
      Receipt.create!(
        :supply => nil,
        :supply_lot => nil,
        :lot_code => "Lot Code",
        :laboratory_name => "Laboratory Name",
        :quantity => 2,
        :code => "Code"
      )
    ])
  end

  it "renders a list of receipts" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Lot Code".to_s, :count => 2
    assert_select "tr>td", :text => "Laboratory Name".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Code".to_s, :count => 2
  end
end
