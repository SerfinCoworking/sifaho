require 'rails_helper'

RSpec.describe "stocks/new", type: :view do
  before(:each) do
    assign(:stock, Stock.new(
      :supply => nil,
      :sector => nil,
      :quantity => 1
    ))
  end

  it "renders new stock form" do
    render

    assert_select "form[action=?][method=?]", stocks_path, "post" do

      assert_select "input[name=?]", "stock[supply_id]"

      assert_select "input[name=?]", "stock[sector_id]"

      assert_select "input[name=?]", "stock[quantity]"
    end
  end
end
