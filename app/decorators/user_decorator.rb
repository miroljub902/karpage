class UserDecorator < Draper::Decorator
  delegate_all

  def initials
    model.name.to_s.split(' ')[0..1].map { |n| n.first.upcase }.join.presence || '?'
  end

  def latest_cars
    model.cars.order(created_at: :desc).limit(4).map { |car| UserCarDecorator.decorate(car) }
  end

  def latest_comments
    model.car_comments.order(created_at: :desc).limit(5).includes(:commentable, :user)
  end

  def posts_for_feed
    followees = model.followees.select('id')
    Post.where("user_id = ? OR user_id IN (#{followees.to_sql})", model.id).sorted.decorate
  end
end
