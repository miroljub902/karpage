class Follow < ActiveRecord::Base
  belongs_to :user
  belongs_to :followee, class_name: 'User'

  after_create :notify_user

  private

  def notify_user
    followee.notifications.create! type: Notification.types[:new_follower], notifiable: self, source: user
  end
end
