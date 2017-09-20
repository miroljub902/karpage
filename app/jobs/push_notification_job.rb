# frozen_string_literal: true

class PushNotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_id)
    notification = Notification.includes(:user, :notifiable, :source).find_by(id: notification_id)
    # TODO: Remove logging
    if notification.nil? && Notification.find_by(id: notification_id)
      Appsignal.send_error(StandardError.new("Notification found without includes: #{notification_id}"))
    elsif notification.nil?
      Appsignal.send_error(StandardError.new("Notification not found: #{notification_id}"))
    else
      notification.update_attribute :status_message, "Pushing... #{notification.unsent?}"
    end
    notification.push! if notification&.unsent?
  end
end
