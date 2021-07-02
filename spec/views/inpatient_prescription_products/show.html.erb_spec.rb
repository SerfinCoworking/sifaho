require 'rails_helper'

RSpec.describe "inpatient_prescription_products/show", type: :view do
  before(:each) do
    @inpatient_prescription_product = assign(:inpatient_prescription_product, InpatientPrescriptionProduct.create!(
      :inpatient_prescription => nil,
      :product => nil,
      :dose_quantiity => 2,
      :interval => 3,
      :status => 4,
      :observation => "MyText",
      :dispensed_by => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(//)
  end
end
