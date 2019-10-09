require 'rails_helper'

RSpec.describe "permission_requests/show", type: :view do
  before(:each) do
    @permission_request = assign(:permission_request, PermissionRequest.create!(
      :user => nil,
      :status => 2,
      :observation => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/MyText/)
  end
end
