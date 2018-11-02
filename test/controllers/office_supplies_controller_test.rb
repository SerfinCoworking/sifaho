require 'test_helper'

class OfficeSuppliesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @office_supply = office_supplies(:one)
  end

  test "should get index" do
    get office_supplies_url
    assert_response :success
  end

  test "should get new" do
    get new_office_supply_url
    assert_response :success
  end

  test "should create office_supply" do
    assert_difference('OfficeSupply.count') do
      post office_supplies_url, params: { office_supply: { description: @office_supply.description, name: @office_supply.name, quantity: @office_supply.quantity, sector_id: @office_supply.sector_id, status: @office_supply.status } }
    end

    assert_redirected_to office_supply_url(OfficeSupply.last)
  end

  test "should show office_supply" do
    get office_supply_url(@office_supply)
    assert_response :success
  end

  test "should get edit" do
    get edit_office_supply_url(@office_supply)
    assert_response :success
  end

  test "should update office_supply" do
    patch office_supply_url(@office_supply), params: { office_supply: { description: @office_supply.description, name: @office_supply.name, quantity: @office_supply.quantity, sector_id: @office_supply.sector_id, status: @office_supply.status } }
    assert_redirected_to office_supply_url(@office_supply)
  end

  test "should destroy office_supply" do
    assert_difference('OfficeSupply.count', -1) do
      delete office_supply_url(@office_supply)
    end

    assert_redirected_to office_supplies_url
  end
end
