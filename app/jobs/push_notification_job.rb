class PushNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(notification_id)
    notification = Notification.includes(:user, :notifiable, :source).find_by(id: notification_id)
    notification.push! if notification&.unsent?
  end
end
