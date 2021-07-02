require 'rails_helper'

RSpec.describe "inpatient_movements/index", type: :view do
  before(:each) do
    assign(:inpatient_movements, [
      InpatientMovement.create!(
        :name => "Name",
        :bed => nil,
        :patient => nil,
        :movement_type => nil,
        :user => nil
      ),
      InpatientMovement.create!(
        :name => "Name",
        :bed => nil,
        :patient => nil,
        :movement_type => nil,
        :user => nil
      )
    ])
  end

  it "renders a list of inpatient_movements" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
