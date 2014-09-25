require 'test_helper'

class PasswordChangeControllerTest < ActionController::TestCase
  test "should get check_password" do
    get :check_password
    assert_response :success
  end

  test "should get change_password" do
    get :change_password
    assert_response :success
  end

end
