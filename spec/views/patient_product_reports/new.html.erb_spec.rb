require 'rails_helper'

RSpec.describe "patient_product_reports/new", type: :view do
  before(:each) do
    assign(:patient_product_report, PatientProductReport.new(
      :patient => nil,
      :supply => nil,
      :product => nil
    ))
  end

  it "renders new patient_product_report form" do
    render

    assert_select "form[action=?][method=?]", patient_product_reports_path, "post" do

      assert_select "input[name=?]", "patient_product_report[patient_id]"

      assert_select "input[name=?]", "patient_product_report[supply_id]"

      assert_select "input[name=?]", "patient_product_report[product_id]"
    end
  end
end
