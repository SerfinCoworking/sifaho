require 'rails_helper'

RSpec.describe "lots/new", type: :view do
  before(:each) do
    assign(:lot, Lot.new(
      :product => nil,
      :laboratory => nil,
      :code => "MyString"
    ))
  end

  it "renders new lot form" do
    render

    assert_select "form[action=?][method=?]", lots_path, "post" do

      assert_select "input[name=?]", "lot[product_id]"

      assert_select "input[name=?]", "lot[laboratory_id]"

      assert_select "input[name=?]", "lot[code]"
    end
  end
end
