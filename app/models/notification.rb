class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notifiable, polymorphic: true
  belongs_to :source, polymorphic: true

  self.inheritance_column = '_disabled'

  after_create :queue_push

  def push!
    raise 'Cannot push non-persisted notification' unless persisted?
    "Notification::#{type.classify}".constantize.new(self).push!
  end

  def sent?
    sent_at.present?
  end

  def unsent?
    !sent?
  end

  private

  def queue_push
    device_id = user.device_info.try(:[], 'user_id').presence
    return unless user.push_setting?(type) && device_id
    PushNotificationJob.perform_later id
  end
end
