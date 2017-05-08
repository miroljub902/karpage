class Notification < ActiveRecord::Base
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
    following_moves_new_car: 'following_moves_new_car',
    following_next_car: 'following_next_car',
    following_dream_car: 'following_dream_car',
    following_new_post: 'following_new_post'
  }

  after_create :queue_push

  def push!
    raise 'Cannot push non-persisted notification' unless persisted?
    "PushNotification::#{type.classify}".constantize.new(self).push!
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
