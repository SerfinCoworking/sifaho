require 'rails_helper'

RSpec.describe "patient_product_reports/index", type: :view do
  before(:each) do
    assign(:patient_product_reports, [
      PatientProductReport.create!(
        :patient => nil,
        :supply => nil,
        :product => nil
      ),
      PatientProductReport.create!(
        :patient => nil,
        :supply => nil,
        :product => nil
      )
    ])
  end

  it "renders a list of patient_product_reports" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
