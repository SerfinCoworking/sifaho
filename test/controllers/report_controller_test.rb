require 'test_helper'

class ReportControllerTest < ActionDispatch::IntegrationTest
  test "should get newOrderingSupply" do
    get report_newOrderingSupply_url
    assert_response :success
  end

end
