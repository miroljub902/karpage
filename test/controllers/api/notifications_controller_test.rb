require 'test_helper'
require_relative '../api_controller_test'

class Api::NotificationsControllerTest < ApiControllerTest
  setup do
    @user = users(:john_doe)
  end

  test 'get user notifications' do
    users(:friend).notifications.create message: 'Not seen', type: 'your_car_like', source: @user, notifiable: cars(:first)
    @user.notifications.create message: 'Dummy', type: 'your_car_like', source: users(:friend), notifiable: cars(:first)
    authorize_user @user
    get :index
    assert_response :ok
    assert_equal 1, json_response.size
    assert_equal 'Dummy', json_response.first['message']
  end
end
