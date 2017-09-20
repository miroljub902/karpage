# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true
  belongs_to :source, polymorphic: true

  self.inheritance_column = '_disabled'

  enum type: {
    your_car_like: 'your_car_like',
    your_post_like: 'your_post_like',
    your_car_comment: 'your_car_comment',
    your_post_comment: 'your_post_comment',
    new_follower: 'new_follower',
    following_new_car: 'following_new_car',
    following_new_first_car: 'following_new_first_car',
    following_new_past_car: 'following_new_past_car',
    following_moves_new_car: 'following_moves_new_car',
    following_next_car: 'following_next_car',
    following_dream_car: 'following_dream_car',
    following_new_post: 'following_new_post'
  }

  before_create :set_message
  after_commit :queue_push, on: :create, unless: -> { @skip_callback }

  scope :recent, -> { order(created_at: :desc) }

  def self.belay_create(user:, source:, type:, notifiable:)
    return if source == user # Skip notifications to "myself"
    last_created_at = user.notifications.recent.find_by(type: type)&.created_at
    return if last_created_at && last_created_at > (ENV['NOTIFICATION_THROTTLE'].presence || 1).to_i.minutes.ago
    Notification.create! user: user, source: source, type: type, notifiable: notifiable
  end

  def push!
    raise 'Cannot push non-persisted notification' unless persisted?
    PushNotification.for(self).push!
  end

  def sent?
    sent_at.present?
  end

  def unsent?
    !sent?
  end

  private

  def set_message
    self.message ||= PushNotification.for(self).message
  end

  def queue_push
    device_id = user.device_info.try(:[], 'user_id').presence
    # TODO: Remove logging
    @skip_callback = true
    update_attribute :status_message, "Queuing... #{user.push_setting?(type)}/#{device_id}"
    return unless user.push_setting?(type) && device_id
    update_attribute :status_message, 'Queued'
    @skip_callback = false
    PushNotificationJob.perform_later id
  end
end
