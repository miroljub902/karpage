require 'test_helper'

class PushNotificationTest < ActiveSupport::TestCase
  setup do
    user = users(:john_doe)
    user.update_attribute :device_info, user_id: 'dummy'
    car = cars(:first)
    car.photos << photos(:one)

    Notification.any_instance.expects(:queue_push)

    @notification = Notification.create!(
      user: user,
      notifiable: car,
      source: users(:friend),
      type: 'your_car_like'
    )
  end

  test 'push!' do
    stub_request(:post, /.*onesignal.com\/.*/)
    @notification.push!
    assert @notification.reload.sent?, "Not sent: #{@notification.status_message}"
  end
end
