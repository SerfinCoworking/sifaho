require 'test_helper'

class VademecumsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @vademecum = vademecums(:one)
  end

  test "should get index" do
    get vademecums_url
    assert_response :success
  end

  test "should get new" do
    get new_vademecum_url
    assert_response :success
  end

  test "should create vademecum" do
    assert_difference('Vademecum.count') do
      post vademecums_url, params: { vademecum: {  } }
    end

    assert_redirected_to vademecum_url(Vademecum.last)
  end

  test "should show vademecum" do
    get vademecum_url(@vademecum)
    assert_response :success
  end

  test "should get edit" do
    get edit_vademecum_url(@vademecum)
    assert_response :success
  end

  test "should update vademecum" do
    patch vademecum_url(@vademecum), params: { vademecum: {  } }
    assert_redirected_to vademecum_url(@vademecum)
  end

  test "should destroy vademecum" do
    assert_difference('Vademecum.count', -1) do
      delete vademecum_url(@vademecum)
    end

    assert_redirected_to vademecums_url
  end
end
