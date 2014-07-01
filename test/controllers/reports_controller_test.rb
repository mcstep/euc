require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  test "should get potential_seats" do
    get :potential_seats
    assert_response :success
  end

end
