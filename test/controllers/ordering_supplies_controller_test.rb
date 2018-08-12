require 'test_helper'

class OrderingSuppliesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ordering_supply = ordering_supplies(:one)
  end

  test "should get index" do
    get ordering_supplies_url
    assert_response :success
  end

  test "should get new" do
    get new_ordering_supply_url
    assert_response :success
  end

  test "should create ordering_supply" do
    assert_difference('OrderingSupply.count') do
      post ordering_supplies_url, params: { ordering_supply: { date_received: @ordering_supply.date_received, observation: @ordering_supply.observation, sector_id: @ordering_supply.sector_id, status: @ordering_supply.status } }
    end

    assert_redirected_to ordering_supply_url(OrderingSupply.last)
  end

  test "should show ordering_supply" do
    get ordering_supply_url(@ordering_supply)
    assert_response :success
  end

  test "should get edit" do
    get edit_ordering_supply_url(@ordering_supply)
    assert_response :success
  end

  test "should update ordering_supply" do
    patch ordering_supply_url(@ordering_supply), params: { ordering_supply: { date_received: @ordering_supply.date_received, observation: @ordering_supply.observation, sector_id: @ordering_supply.sector_id, status: @ordering_supply.status } }
    assert_redirected_to ordering_supply_url(@ordering_supply)
  end

  test "should destroy ordering_supply" do
    assert_difference('OrderingSupply.count', -1) do
      delete ordering_supply_url(@ordering_supply)
    end

    assert_redirected_to ordering_supplies_url
  end
end
