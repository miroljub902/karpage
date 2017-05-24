class PushNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(notification_id)
    notification = Notification.includes(:user, :notifiable, :source).find_by(id: notification_id)
    # TODO: Remove logging
    Appsignal.send_error(StandardError.new("Notification not found: #{notification_id}")) unless notification
    notification.update_attribute :status_message, "Pushing... #{notification.unsent?}" if notification
    notification.push! if notification&.unsent?
  end
end
