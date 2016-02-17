class Like < ActiveRecord::Base
  belongs_to :likeable, polymorphic: true, counter_cache: true
  belongs_to :user

  def self.like!(likeable, user)
    find_or_create_by! likeable: likeable, user: user
  end

  def self.unlike!(likeable, user)
    where(likeable: likeable, user: user).destroy_all
  end
end
