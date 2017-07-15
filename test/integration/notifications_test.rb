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
      xhr :put, toggle_like_car_path(@user, @car), format: :js
      xhr :put, toggle_like_car_path(@user, @car), format: :js
      xhr :put, toggle_like_car_path(@user, @car), format: :js
      assert_response :ok
    end
  end
end
