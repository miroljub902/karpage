class Like < ActiveRecord::Base
  belongs_to :likeable, polymorphic: true, counter_cache: true
  belongs_to :user

  after_create :notify_user

  def self.like!(likeable, user)
    find_or_create_by! likeable: likeable, user: user
  rescue ActiveRecord::RecordNotUnique
    find_by! likeable: likeable, user: user
  end

  def self.unlike!(likeable, user)
    where(likeable: likeable, user: user).destroy_all
  end

  private

  def notify_user
    owner = likeable.try(:user)
    return unless owner
    type = case likeable
           when Car
             Notification.types[:your_car_like]
           when Post
             Notification.types[:your_post_like]
           end
    Notification.belay_create user: owner, type: type, notifiable: likeable, source: user if type
    true
  end
end
