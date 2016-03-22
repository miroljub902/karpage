class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, polymorphic: true, counter_cache: true

  scope :sorted, -> { order(created_at: :desc) }
end
