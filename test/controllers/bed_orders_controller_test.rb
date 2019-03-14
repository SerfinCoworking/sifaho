require 'test_helper'

class BedOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bed_order = bed_orders(:one)
  end

  test "should get index" do
    get bed_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_bed_order_url
    assert_response :success
  end

  test "should create bed_order" do
    assert_difference('BedOrder.count') do
      post bed_orders_url, params: { bed_order: { audited_by_id: @bed_order.audited_by_id, created_by_id: @bed_order.created_by_id, date_received: @bed_order.date_received, deleted_at: @bed_order.deleted_at, patient_id: @bed_order.patient_id, received_by_id: @bed_order.received_by_id, remit_code: @bed_order.remit_code, sent_date: @bed_order.sent_date, sent_dy: @bed_order.sent_dy, sent_request_by_id_id: @bed_order.sent_request_by_id_id, status: @bed_order.status } }
    end

    assert_redirected_to bed_order_url(BedOrder.last)
  end

  test "should show bed_order" do
    get bed_order_url(@bed_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_bed_order_url(@bed_order)
    assert_response :success
  end

  test "should update bed_order" do
    patch bed_order_url(@bed_order), params: { bed_order: { audited_by_id: @bed_order.audited_by_id, created_by_id: @bed_order.created_by_id, date_received: @bed_order.date_received, deleted_at: @bed_order.deleted_at, patient_id: @bed_order.patient_id, received_by_id: @bed_order.received_by_id, remit_code: @bed_order.remit_code, sent_date: @bed_order.sent_date, sent_dy: @bed_order.sent_dy, sent_request_by_id_id: @bed_order.sent_request_by_id_id, status: @bed_order.status } }
    assert_redirected_to bed_order_url(@bed_order)
  end

  test "should destroy bed_order" do
    assert_difference('BedOrder.count', -1) do
      delete bed_order_url(@bed_order)
    end

    assert_redirected_to bed_orders_url
  end
end
