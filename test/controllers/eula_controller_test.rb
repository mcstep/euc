require 'test_helper'

class EulaControllerTest < ActionController::TestCase
  test "should get accept" do
    get :accept
    assert_response :success
  end

end
