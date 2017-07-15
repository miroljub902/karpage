class Follow < ActiveRecord::Base
  belongs_to :user
  belongs_to :followee, class_name: 'User'
  has_many :notifications, as: :notifiable, dependent: :delete_all

  after_create :notify_user

  validate -> {
    errors.add :followee_id, 'You cannot follow yourself' if followee_id == user_id
  }

  private

  def notify_user
    Notification.belay_create user: followee, type: Notification.types[:new_follower], notifiable: self, source: user
  end
end
