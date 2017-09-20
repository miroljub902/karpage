# frozen_string_literal: true

require 'test_helper'

class NotificationsTest < ActionDispatch::IntegrationTest
  setup do
    mock_request :s3
    @user   = users(:john_doe)
    @friend = users(:friend)
    @car    = cars(:current)
    @user.cars << @car
    Notification.delete_all
  end

  test 'do not spam notifications' do
    sign_in @friend, 'password'
    assert_difference '@user.notifications.count', +1 do
      put toggle_like_car_path(@user, @car), xhr: true
      put toggle_like_car_path(@user, @car), xhr: true
      put toggle_like_car_path(@user, @car), xhr: true
      assert_response :ok
    end
  end
end
