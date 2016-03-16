class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :delete_all

  attachment :photo

  validate :validate_presence_of_photo

  scope :sorted, -> { order(created_at: :desc) }
  scope :with_photo, -> { where.not(photo_id: nil) }

  paginates_per 15

  private

  def validate_presence_of_photo
    return if photo_id.present?
    errors.add :photo, :blank
  end
end
