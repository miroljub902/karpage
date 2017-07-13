require 'test_helper'

class PushNotificationTest < ActiveSupport::TestCase
  setup do
    @user = users(:john_doe)
    @user.update_attribute :device_info, user_id: 'dummy'
    @car = cars(:first)
    @car.photos << photos(:one)

    # Cannot test this since we use an after_commit hook now
    # Notification.any_instance.expects(:queue_push).at_least_once

    @notification = Notification.create!(
      user: @user,
      notifiable: @car,
      source: users(:friend),
      type: 'your_car_like'
    )
  end

  test 'push!' do
    stub_request(:post, /.*onesignal.com\/.*/)
    @notification.push!
    assert @notification.reload.sent?, "Not sent: #{@notification.status_message}"
  end

  test 'do not create notification for myself' do
    Timecop.freeze Date.new(3000, 1, 1) do
      notification = Notification.belay_create(user: @user, source: @user, notifiable: @car, type: 'your_car_like')
      assert notification.nil?, 'No notification should be created!'
    end
  end

  test 'do not spam notifications' do
    Timecop.freeze Date.new(3000, 1, 1) do
      notification = Notification.belay_create(user: @user, source: users(:friend), notifiable: @car, type: 'your_car_like')
      assert notification.present?, 'Notification was not created!'
      notification = Notification.belay_create(user: @user, source: users(:friend), notifiable: @car, type: 'your_car_like')
      assert notification.nil?, 'No notification should be created!'
    end
  end
end
