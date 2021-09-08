require 'rails_helper'

RSpec.describe "unify_products/index", type: :view do
  before(:each) do
    assign(:unify_products, [
      UnifyProduct.create!(
        :origin_product => nil,
        :target_product => nil,
        :status => 2,
        :observation => "MyText"
      ),
      UnifyProduct.create!(
        :origin_product => nil,
        :target_product => nil,
        :status => 2,
        :observation => "MyText"
      )
    ])
  end

  it "renders a list of unify_products" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
