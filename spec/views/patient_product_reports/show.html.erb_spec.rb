require 'rails_helper'

RSpec.describe "patient_product_reports/show", type: :view do
  before(:each) do
    @patient_product_report = assign(:patient_product_report, PatientProductReport.create!(
      :patient => nil,
      :supply => nil,
      :product => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
