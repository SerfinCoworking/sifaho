require 'rails_helper'

RSpec.describe "unify_products/new", type: :view do
  before(:each) do
    assign(:unify_product, UnifyProduct.new(
      :origin_product => nil,
      :target_product => nil,
      :status => 1,
      :observation => "MyText"
    ))
  end

  it "renders new unify_product form" do
    render

    assert_select "form[action=?][method=?]", unify_products_path, "post" do

      assert_select "input[name=?]", "unify_product[origin_product_id]"

      assert_select "input[name=?]", "unify_product[target_product_id]"

      assert_select "input[name=?]", "unify_product[status]"

      assert_select "textarea[name=?]", "unify_product[observation]"
    end
  end
end
