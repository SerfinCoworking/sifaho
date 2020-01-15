require 'rails_helper'

RSpec.describe "lots/show", type: :view do
  before(:each) do
    @lot = assign(:lot, Lot.create!(
      :product => nil,
      :laboratory => nil,
      :code => "Code"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Code/)
  end
end
