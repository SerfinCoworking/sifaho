require 'rails_helper'

RSpec.describe "internal_order_templates/edit", type: :view do
  before(:each) do
    @internal_order_template = assign(:internal_order_template, InternalOrderTemplate.create!(
      :name => "MyString",
      :owner_sector => nil,
      :detination_sector => nil,
      :order_type => 1
    ))
  end

  it "renders the edit internal_order_template form" do
    render

    assert_select "form[action=?][method=?]", internal_order_template_path(@internal_order_template), "post" do

      assert_select "input[name=?]", "internal_order_template[name]"

      assert_select "input[name=?]", "internal_order_template[owner_sector_id]"

      assert_select "input[name=?]", "internal_order_template[detination_sector_id]"

      assert_select "input[name=?]", "internal_order_template[order_type]"
    end
  end
end
