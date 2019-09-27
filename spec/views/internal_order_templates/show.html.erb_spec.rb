require 'rails_helper'

RSpec.describe "internal_order_templates/show", type: :view do
  before(:each) do
    @internal_order_template = assign(:internal_order_template, InternalOrderTemplate.create!(
      :name => "Name",
      :owner_sector => nil,
      :detination_sector => nil,
      :order_type => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
  end
end
