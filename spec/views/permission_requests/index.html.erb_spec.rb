require 'rails_helper'

RSpec.describe "permission_requests/index", type: :view do
  before(:each) do
    assign(:permission_requests, [
      PermissionRequest.create!(
        :user => nil,
        :status => 2,
        :observation => "MyText"
      ),
      PermissionRequest.create!(
        :user => nil,
        :status => 2,
        :observation => "MyText"
      )
    ])
  end

  it "renders a list of permission_requests" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
