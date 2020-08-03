require 'rails_helper'

RSpec.describe "receipts/new", type: :view do
  before(:each) do
    assign(:receipt, Receipt.new(
      :supply => nil,
      :supply_lot => nil,
      :lot_code => "MyString",
      :laboratory_name => "MyString",
      :quantity => 1,
      :code => "MyString"
    ))
  end

  it "renders new receipt form" do
    render

    assert_select "form[action=?][method=?]", receipts_path, "post" do

      assert_select "input[name=?]", "receipt[supply_id]"

      assert_select "input[name=?]", "receipt[supply_lot_id]"

      assert_select "input[name=?]", "receipt[lot_code]"

      assert_select "input[name=?]", "receipt[laboratory_name]"

      assert_select "input[name=?]", "receipt[quantity]"

      assert_select "input[name=?]", "receipt[code]"
    end
  end
end
