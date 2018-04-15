# frozen_string_literal: true

class Comment < ApplicationRecord
  include MentionsNotifier
  include HashtagsHandler

  belongs_to :user
  belongs_to :commentable, polymorphic: true, counter_cache: true
  has_many :notifications, as: :notifiable, dependent: :delete_all
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :recent_comments, -> { sorted.page(1).per(10) }, class_name: 'Comment', as: :commentable

  attachment :photo, type: :image

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

  def to_s
    id
  end

  private

  def notify_user
    type = case commentable
           when Car
             Notification.types[:your_car_comment]
           when Post
             Notification.types[:your_post_comment]
           when Comment
             Notification.types[:comment_replies]
           end
    Notification.belay_create user: commentable.user, type: type, notifiable: self, source: user if type
    true
  end
end
