class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :delete_all

  attachment :photo

  validate :validate_presence_of_photo

  scope :sorted, -> { order(created_at: :desc) }
  scope :with_photo, -> { where.not(photo_id: nil) }
  scope :not_blocked, -> (user) {
    if user
      joins(:user).where.not(users: { id: user.blocks.select(:blocked_user_id) })
    else
      all
    end
  }

  paginates_per 15

  def toggle_like!(user)
    if (like = likes.find_by(user: user))
      like.destroy
    else
      likes.create! user: user
    end
  end

  private

  def validate_presence_of_photo
    return if photo || photo_id.present?
    errors.add :photo, :blank
  end
end
