require 'test_helper'

class InternalOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @internal_order = internal_orders(:one)
  end

  test "should get index" do
    get internal_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_internal_order_url
    assert_response :success
  end

  test "should create internal_order" do
    assert_difference('InternalOrder.count') do
      post internal_orders_url, params: { internal_order: { date_received: @internal_order.date_received, date_sent: @internal_order.date_sent, observation: @internal_order.observation, responsable_id: @internal_order.responsable_id } }
    end

    assert_redirected_to internal_order_url(InternalOrder.last)
  end

  test "should show internal_order" do
    get internal_order_url(@internal_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_internal_order_url(@internal_order)
    assert_response :success
  end

  test "should update internal_order" do
    patch internal_order_url(@internal_order), params: { internal_order: { date_received: @internal_order.date_received, date_sent: @internal_order.date_sent, observation: @internal_order.observation, responsable_id: @internal_order.responsable_id } }
    assert_redirected_to internal_order_url(@internal_order)
  end

  test "should destroy internal_order" do
    assert_difference('InternalOrder.count', -1) do
      delete internal_order_url(@internal_order)
    end

    assert_redirected_to internal_orders_url
  end
end
