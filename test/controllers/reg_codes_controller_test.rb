require 'test_helper'

class RegCodesControllerTest < ActionController::TestCase
  setup do
    @reg_code = reg_codes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reg_codes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create reg_code" do
    assert_difference('RegCode.count') do
      post :create, reg_code: { account_type: @reg_code.account_type, account_validity: @reg_code.account_validity, code: @reg_code.code, registrations: @reg_code.registrations, status: @reg_code.status, valid_from: @reg_code.valid_from, valid_to: @reg_code.valid_to }
    end

    assert_redirected_to reg_code_path(assigns(:reg_code))
  end

  test "should show reg_code" do
    get :show, id: @reg_code
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @reg_code
    assert_response :success
  end

  test "should update reg_code" do
    patch :update, id: @reg_code, reg_code: { account_type: @reg_code.account_type, account_validity: @reg_code.account_validity, code: @reg_code.code, registrations: @reg_code.registrations, status: @reg_code.status, valid_from: @reg_code.valid_from, valid_to: @reg_code.valid_to }
    assert_redirected_to reg_code_path(assigns(:reg_code))
  end

  test "should destroy reg_code" do
    assert_difference('RegCode.count', -1) do
      delete :destroy, id: @reg_code
    end

    assert_redirected_to reg_codes_path
  end
end
