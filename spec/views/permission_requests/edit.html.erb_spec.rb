require 'rails_helper'

RSpec.describe "permission_requests/edit", type: :view do
  before(:each) do
    @permission_request = assign(:permission_request, PermissionRequest.create!(
      :user => nil,
      :status => 1,
      :observation => "MyText"
    ))
  end

  it "renders the edit permission_request form" do
    render

    assert_select "form[action=?][method=?]", permission_request_path(@permission_request), "post" do

      assert_select "input[name=?]", "permission_request[user_id]"

      assert_select "input[name=?]", "permission_request[status]"

      assert_select "textarea[name=?]", "permission_request[observation]"
    end
  end
end
