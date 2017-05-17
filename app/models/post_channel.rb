class PostChannel
  attr_reader :posts

  def initialize(id, user: nil, page: 1, per: Post.default_per_page)
    @posts = base_scope(id).with_photo.sorted.page(page).per(per || Post.default_per_page)
    @posts = @posts.not_blocked(user).select_all.select_upvoted(user) if user
  end

  private

  DAYS = %w[sunday monday tuesday wednesday thursday friday saturday].freeze
  DOW_QUERY = "EXTRACT(DOW FROM (posts.created_at + INTERVAL '#{Time.zone.utc_offset} second')) = ?".freeze

  def base_scope(id)
    day = DAYS.index(id)
    return Post.none unless day
    Post
      .order(upvotes_count: :desc, created_at: :desc)
      .where(DOW_QUERY, DAYS.index(id))
  end
end
