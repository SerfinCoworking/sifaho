require 'rails_helper'

RSpec.describe "internal_order_templates/new", type: :view do
  before(:each) do
    assign(:internal_order_template, InternalOrderTemplate.new(
      :name => "MyString",
      :owner_sector => nil,
      :detination_sector => nil,
      :order_type => 1
    ))
  end

  it "renders new internal_order_template form" do
    render

    assert_select "form[action=?][method=?]", internal_order_templates_path, "post" do

      assert_select "input[name=?]", "internal_order_template[name]"

      assert_select "input[name=?]", "internal_order_template[owner_sector_id]"

      assert_select "input[name=?]", "internal_order_template[detination_sector_id]"

      assert_select "input[name=?]", "internal_order_template[order_type]"
    end
  end
end
