class Like < ActiveRecord::Base
  belongs_to :likeable, polymorphic: true, counter_cache: true
  belongs_to :user

  after_create :notify_user

  def self.like!(likeable, user)
    find_or_create_by! likeable: likeable, user: user
  end

  def self.unlike!(likeable, user)
    where(likeable: likeable, user: user).destroy_all
  end

  private

  def notify_user
    owner = likeable.try(:user)
    return unless owner
    case likeable
    when Car
      owner.notifications.create! type: 'your_car_like', notifiable: likeable, source: user
    when Post
      owner.notifications.create! type: 'your_post_like', notifiable: likeable, source: user
    end
    true
  end
end
