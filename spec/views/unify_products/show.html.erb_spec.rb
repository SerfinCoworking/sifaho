require 'rails_helper'

RSpec.describe "unify_products/show", type: :view do
  before(:each) do
    @unify_product = assign(:unify_product, UnifyProduct.create!(
      :origin_product => nil,
      :target_product => nil,
      :status => 2,
      :observation => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/MyText/)
  end
end
