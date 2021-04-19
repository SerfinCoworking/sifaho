require 'rails_helper'

RSpec.describe "inpatient_prescriptions/edit", type: :view do
  before(:each) do
    @inpatient_prescription = assign(:inpatient_prescription, InpatientPrescription.create!(
      :patient => nil,
      :professional => nil,
      :bed => nil,
      :remit_code => "MyString",
      :observation => "MyText",
      :status => 1
    ))
  end

  it "renders the edit inpatient_prescription form" do
    render

    assert_select "form[action=?][method=?]", inpatient_prescription_path(@inpatient_prescription), "post" do

      assert_select "input[name=?]", "inpatient_prescription[patient_id]"

      assert_select "input[name=?]", "inpatient_prescription[professional_id]"

      assert_select "input[name=?]", "inpatient_prescription[bed_id]"

      assert_select "input[name=?]", "inpatient_prescription[remit_code]"

      assert_select "textarea[name=?]", "inpatient_prescription[observation]"

      assert_select "input[name=?]", "inpatient_prescription[status]"
    end
  end
end
