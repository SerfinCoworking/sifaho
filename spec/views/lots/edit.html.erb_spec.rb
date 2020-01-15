require 'rails_helper'

RSpec.describe "lots/edit", type: :view do
  before(:each) do
    @lot = assign(:lot, Lot.create!(
      :product => nil,
      :laboratory => nil,
      :code => "MyString"
    ))
  end

  it "renders the edit lot form" do
    render

    assert_select "form[action=?][method=?]", lot_path(@lot), "post" do

      assert_select "input[name=?]", "lot[product_id]"

      assert_select "input[name=?]", "lot[laboratory_id]"

      assert_select "input[name=?]", "lot[code]"
    end
  end
end
