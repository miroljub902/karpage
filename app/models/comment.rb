# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true, counter_cache: true
  has_many :notifications, as: :notifiable, dependent: :delete_all

  validates :body, presence: true

  after_create :notify_user

  scope :sorted, -> { order(created_at: :desc) }
  scope :not_blocked, ->(user) {
    if user
      joins(:user).where.not(users: { id: user.blocks.select(:blocked_user_id) })
    else
      all
    end
  }

  private

  def notify_user
    type = case commentable
           when Car
             Notification.types[:your_car_comment]
           when Post
             Notification.types[:your_post_comment]
           end
    Notification.belay_create user: commentable.user, type: type, notifiable: self, source: user if type
    true
  end
end
