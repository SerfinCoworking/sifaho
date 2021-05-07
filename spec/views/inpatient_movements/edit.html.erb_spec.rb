require 'rails_helper'

RSpec.describe "inpatient_movements/edit", type: :view do
  before(:each) do
    @inpatient_movement = assign(:inpatient_movement, InpatientMovement.create!(
      :name => "MyString",
      :bed => nil,
      :patient => nil,
      :movement_type => nil,
      :user => nil
    ))
  end

  it "renders the edit inpatient_movement form" do
    render

    assert_select "form[action=?][method=?]", inpatient_movement_path(@inpatient_movement), "post" do

      assert_select "input[name=?]", "inpatient_movement[name]"

      assert_select "input[name=?]", "inpatient_movement[bed_id]"

      assert_select "input[name=?]", "inpatient_movement[patient_id]"

      assert_select "input[name=?]", "inpatient_movement[movement_type_id]"

      assert_select "input[name=?]", "inpatient_movement[user_id]"
    end
  end
end
