require 'test_helper'

class SupplyLotsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @supply_lot = supply_lots(:one)
  end

  test "should get index" do
    get supply_lots_url
    assert_response :success
  end

  test "should get new" do
    get new_supply_lot_url
    assert_response :success
  end

  test "should create supply_lot" do
    assert_difference('SupplyLot.count') do
      post supply_lots_url, params: { supply_lot: { code: @supply_lot.code, date_received: @supply_lot.date_received, expiry_date: @supply_lot.expiry_date, initial_quantity: @supply_lot.initial_quantity, quantity: @supply_lot.quantity, status: @supply_lot.status } }
    end

    assert_redirected_to supply_lot_url(SupplyLot.last)
  end

  test "should show supply_lot" do
    get supply_lot_url(@supply_lot)
    assert_response :success
  end

  test "should get edit" do
    get edit_supply_lot_url(@supply_lot)
    assert_response :success
  end

  test "should update supply_lot" do
    patch supply_lot_url(@supply_lot), params: { supply_lot: { code: @supply_lot.code, date_received: @supply_lot.date_received, expiry_date: @supply_lot.expiry_date, initial_quantity: @supply_lot.initial_quantity, quantity: @supply_lot.quantity, status: @supply_lot.status } }
    assert_redirected_to supply_lot_url(@supply_lot)
  end

  test "should destroy supply_lot" do
    assert_difference('SupplyLot.count', -1) do
      delete supply_lot_url(@supply_lot)
    end

    assert_redirected_to supply_lots_url
  end
end
