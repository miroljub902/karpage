class Post < ActiveRecord::Base
  belongs_to :user

  attachment :photo

  validates :body, presence: true

  scope :sorted, -> { order(created_at: :desc) }
end
