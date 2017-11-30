require 'test_helper'

class OrderStatusesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get order_statuses_new_url
    assert_response :success
  end

  test "should get create" do
    get order_statuses_create_url
    assert_response :success
  end

  test "should get edit" do
    get order_statuses_edit_url
    assert_response :success
  end

  test "should get destroy" do
    get order_statuses_destroy_url
    assert_response :success
  end

end
