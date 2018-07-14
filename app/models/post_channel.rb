# frozen_string_literal: true

class PostChannel < ApplicationRecord
  has_many :posts, dependent: :nullify

  scope :active, -> { where(active: true) }
  scope :sorted, -> { order(ordering: :asc) }

  attachment :image, type: :image
  attachment :thumb, type: :image

  def to_s
    name
  end

  def self.get_posts(channel, user: nil, page: 1, per: Post.default_per_page, sort: :upvotes)
    posts = case sort
            when 'newest'
              channel.posts.order(created_at: :desc, upvotes_count: :desc)
            else
              channel.posts.order(upvotes_count: :desc, created_at: :desc)
            end
    posts = posts.with_photo_or_video.sorted.page(page).per(per || Post.default_per_page)
    posts = posts.not_blocked(user).select_all.select_upvoted(user) if user
    posts
  end
end
