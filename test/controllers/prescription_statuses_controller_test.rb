require 'test_helper'

class PrescriptionStatusesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get prescription_statuses_new_url
    assert_response :success
  end

  test "should get create" do
    get prescription_statuses_create_url
    assert_response :success
  end

  test "should get edit" do
    get prescription_statuses_edit_url
    assert_response :success
  end

  test "should get destroy" do
    get prescription_statuses_destroy_url
    assert_response :success
  end

end
