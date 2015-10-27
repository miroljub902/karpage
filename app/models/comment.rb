class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  scope :sorted, -> { order(created_at: :desc) }
end
