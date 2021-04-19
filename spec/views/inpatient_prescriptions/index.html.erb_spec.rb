require 'rails_helper'

RSpec.describe "inpatient_prescriptions/index", type: :view do
  before(:each) do
    assign(:inpatient_prescriptions, [
      InpatientPrescription.create!(
        :patient => nil,
        :professional => nil,
        :bed => nil,
        :remit_code => "Remit Code",
        :observation => "MyText",
        :status => 2
      ),
      InpatientPrescription.create!(
        :patient => nil,
        :professional => nil,
        :bed => nil,
        :remit_code => "Remit Code",
        :observation => "MyText",
        :status => 2
      )
    ])
  end

  it "renders a list of inpatient_prescriptions" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Remit Code".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
