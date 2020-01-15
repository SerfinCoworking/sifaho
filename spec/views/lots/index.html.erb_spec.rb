require 'rails_helper'

RSpec.describe "lots/index", type: :view do
  before(:each) do
    assign(:lots, [
      Lot.create!(
        :product => nil,
        :laboratory => nil,
        :code => "Code"
      ),
      Lot.create!(
        :product => nil,
        :laboratory => nil,
        :code => "Code"
      )
    ])
  end

  it "renders a list of lots" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Code".to_s, :count => 2
  end
end
