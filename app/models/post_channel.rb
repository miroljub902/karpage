class PostChannel < ActiveRecord::Base
  has_many :posts, dependent: :nullify

  def self.get_posts(channel, user: nil, page: 1, per: Post.default_per_page)
    posts = channel.posts.order(upvotes_count: :desc, created_at: :desc)
    posts = posts.with_photo.sorted.page(page).per(per || Post.default_per_page)
    posts = posts.not_blocked(user).select_all.select_upvoted(user) if user
    posts
  end
end
