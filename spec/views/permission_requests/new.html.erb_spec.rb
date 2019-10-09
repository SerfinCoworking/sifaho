require 'rails_helper'

RSpec.describe "permission_requests/new", type: :view do
  before(:each) do
    assign(:permission_request, PermissionRequest.new(
      :user => nil,
      :status => 1,
      :observation => "MyText"
    ))
  end

  it "renders new permission_request form" do
    render

    assert_select "form[action=?][method=?]", permission_requests_path, "post" do

      assert_select "input[name=?]", "permission_request[user_id]"

      assert_select "input[name=?]", "permission_request[status]"

      assert_select "textarea[name=?]", "permission_request[observation]"
    end
  end
end
