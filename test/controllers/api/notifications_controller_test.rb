# frozen_string_literal: true

require 'test_helper'
require_relative '../api_controller_test'

class Api::NotificationsControllerTest < ApiControllerTest
  setup do
    @user = users(:john_doe)
    Notification.delete_all
    mock_request 's3'
  end

  test 'get user notifications' do
    other_user     = users(:friend)
    other_car      = cars(:current)
    other_car.user = other_user
    other_car.save!
    other_user.notifications.create message: 'Not seen', type: 'your_car_like', source: @user, notifiable: other_car
    @user.notifications.create message: 'Dummy', type: 'your_car_like', source: other_user, notifiable: cars(:first)
    authorize_user @user
    get :index
    assert_response :ok
    assert_equal 1, json_response.size
    assert_equal 'Dummy', json_response['notifications'].first['message']
  end

  test 'new_follower notification returns following true' do
    other_user = users(:friend)
    @user.follow! other_user
    other_user.follow! @user
    authorize_user @user
    get :index
    assert json_response['notifications'].first['following']
  end
end
