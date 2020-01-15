require 'rails_helper'

RSpec.describe "products/edit", type: :view do
  before(:each) do
    @product = assign(:product, Product.create!(
      :unity => nil,
      :code => "MyString",
      :name => "MyString",
      :description => "MyText",
      :observation => "MyText"
    ))
  end

  it "renders the edit product form" do
    render

    assert_select "form[action=?][method=?]", product_path(@product), "post" do

      assert_select "input[name=?]", "product[unity_id]"

      assert_select "input[name=?]", "product[code]"

      assert_select "input[name=?]", "product[name]"

      assert_select "textarea[name=?]", "product[description]"

      assert_select "textarea[name=?]", "product[observation]"
    end
  end
end
