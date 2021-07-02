require 'rails_helper'

RSpec.describe "inpatient_prescription_products/new", type: :view do
  before(:each) do
    assign(:inpatient_prescription_product, InpatientPrescriptionProduct.new(
      :inpatient_prescription => nil,
      :product => nil,
      :dose_quantiity => 1,
      :interval => 1,
      :status => 1,
      :observation => "MyText",
      :dispensed_by => nil
    ))
  end

  it "renders new inpatient_prescription_product form" do
    render

    assert_select "form[action=?][method=?]", inpatient_prescription_products_path, "post" do

      assert_select "input[name=?]", "inpatient_prescription_product[inpatient_prescription_id]"

      assert_select "input[name=?]", "inpatient_prescription_product[product_id]"

      assert_select "input[name=?]", "inpatient_prescription_product[dose_quantiity]"

      assert_select "input[name=?]", "inpatient_prescription_product[interval]"

      assert_select "input[name=?]", "inpatient_prescription_product[status]"

      assert_select "textarea[name=?]", "inpatient_prescription_product[observation]"

      assert_select "input[name=?]", "inpatient_prescription_product[dispensed_by_id]"
    end
  end
end
