require 'rails_helper'

RSpec.describe "inpatient_prescriptions/new", type: :view do
  before(:each) do
    assign(:inpatient_prescription, InpatientPrescription.new(
      :patient => nil,
      :professional => nil,
      :bed => nil,
      :remit_code => "MyString",
      :observation => "MyText",
      :status => 1
    ))
  end

  it "renders new inpatient_prescription form" do
    render

    assert_select "form[action=?][method=?]", inpatient_prescriptions_path, "post" do

      assert_select "input[name=?]", "inpatient_prescription[patient_id]"

      assert_select "input[name=?]", "inpatient_prescription[professional_id]"

      assert_select "input[name=?]", "inpatient_prescription[bed_id]"

      assert_select "input[name=?]", "inpatient_prescription[remit_code]"

      assert_select "textarea[name=?]", "inpatient_prescription[observation]"

      assert_select "input[name=?]", "inpatient_prescription[status]"
    end
  end
end
