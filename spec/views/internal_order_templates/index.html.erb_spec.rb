require 'rails_helper'

RSpec.describe "internal_order_templates/index", type: :view do
  before(:each) do
    assign(:internal_order_templates, [
      InternalOrderTemplate.create!(
        :name => "Name",
        :owner_sector => nil,
        :detination_sector => nil,
        :order_type => 2
      ),
      InternalOrderTemplate.create!(
        :name => "Name",
        :owner_sector => nil,
        :detination_sector => nil,
        :order_type => 2
      )
    ])
  end

  it "renders a list of internal_order_templates" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
