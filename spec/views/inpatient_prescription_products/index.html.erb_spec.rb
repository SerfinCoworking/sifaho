require 'rails_helper'

RSpec.describe "inpatient_prescription_products/index", type: :view do
  before(:each) do
    assign(:inpatient_prescription_products, [
      InpatientPrescriptionProduct.create!(
        :inpatient_prescription => nil,
        :product => nil,
        :dose_quantiity => 2,
        :interval => 3,
        :status => 4,
        :observation => "MyText",
        :dispensed_by => nil
      ),
      InpatientPrescriptionProduct.create!(
        :inpatient_prescription => nil,
        :product => nil,
        :dose_quantiity => 2,
        :interval => 3,
        :status => 4,
        :observation => "MyText",
        :dispensed_by => nil
      )
    ])
  end

  it "renders a list of inpatient_prescription_products" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
