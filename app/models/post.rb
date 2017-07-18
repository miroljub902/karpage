class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :post_channel
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :delete_all
  has_many :notifications, as: :notifiable, dependent: :delete_all

  attachment :photo, type: :image

  validate :validate_presence_of_photo, :validate_photo_size

  scope :sorted, -> { order(created_at: :desc) }
  scope :global, -> { where(post_channel_id: nil) }
  scope :with_photo, -> { where.not(photo_id: nil) }
  scope :not_blocked, -> (user) {
    if user
      joins(:user).where.not(users: { id: user.blocks.select(:blocked_user_id) })
    else
      all
    end
  }

  scope :select_all, -> { select('posts.*') }
  scope :select_upvoted, -> (user) do
    joins("LEFT OUTER JOIN upvotes ON upvotes.voteable_type = 'Post' AND upvotes.voteable_id = posts.id AND upvotes.user_id = #{user.id}")
      .select('(upvotes.id IS NOT NULL) AS upvoted')
  end

  scope :select_liked, -> (user) do
    joins("LEFT OUTER JOIN likes ON likes.likeable_type = 'Post' AND likes.likeable_id = posts.id AND likes.user_id = #{user.id}")
      .select('(likes.id IS NOT NULL) AS liked')
  end

  paginates_per 15

  def post_channel_name=(name)
    self.post_channel = PostChannel.find_by(name: name)
  end

  def toggle_like!(user)
    if (like = likes.find_by(user: user))
      like.destroy
    else
      likes.create! user: user
    end
  end

  concerning :Notifications do
    included do
      after_create -> {
        type = Notification.types[:following_new_post]
        user.followers.each do |follower|
          Notification.belay_create user: follower, type: type, notifiable: self, source: user
        end
      }
    end
  end

  private

  def validate_presence_of_photo
    return if photo || photo_id.present?
    errors.add :photo, :blank
  end

  def validate_photo_size
    return if !photo || photo.size < photo.backend.max_size
    errors.add :photo, :too_large
  end
end
