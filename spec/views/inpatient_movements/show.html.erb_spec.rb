require 'rails_helper'

RSpec.describe "inpatient_movements/show", type: :view do
  before(:each) do
    @inpatient_movement = assign(:inpatient_movement, InpatientMovement.create!(
      :name => "Name",
      :bed => nil,
      :patient => nil,
      :movement_type => nil,
      :user => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
