class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :delete_all

  attachment :photo

  validates :body, presence: true

  scope :sorted, -> { order(created_at: :desc) }

  paginates_per 15
end
