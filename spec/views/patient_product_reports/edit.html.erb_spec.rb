require 'rails_helper'

RSpec.describe "patient_product_reports/edit", type: :view do
  before(:each) do
    @patient_product_report = assign(:patient_product_report, PatientProductReport.create!(
      :patient => nil,
      :supply => nil,
      :product => nil
    ))
  end

  it "renders the edit patient_product_report form" do
    render

    assert_select "form[action=?][method=?]", patient_product_report_path(@patient_product_report), "post" do

      assert_select "input[name=?]", "patient_product_report[patient_id]"

      assert_select "input[name=?]", "patient_product_report[supply_id]"

      assert_select "input[name=?]", "patient_product_report[product_id]"
    end
  end
end
