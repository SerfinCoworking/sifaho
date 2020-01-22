require 'rails_helper'

RSpec.describe "stocks/edit", type: :view do
  before(:each) do
    @stock = assign(:stock, Stock.create!(
      :supply => nil,
      :sector => nil,
      :quantity => 1
    ))
  end

  it "renders the edit stock form" do
    render

    assert_select "form[action=?][method=?]", stock_path(@stock), "post" do

      assert_select "input[name=?]", "stock[supply_id]"

      assert_select "input[name=?]", "stock[sector_id]"

      assert_select "input[name=?]", "stock[quantity]"
    end
  end
end
