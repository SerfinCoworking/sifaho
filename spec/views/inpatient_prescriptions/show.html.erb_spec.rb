require 'rails_helper'

RSpec.describe "inpatient_prescriptions/show", type: :view do
  before(:each) do
    @inpatient_prescription = assign(:inpatient_prescription, InpatientPrescription.create!(
      :patient => nil,
      :professional => nil,
      :bed => nil,
      :remit_code => "Remit Code",
      :observation => "MyText",
      :status => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Remit Code/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/2/)
  end
end
