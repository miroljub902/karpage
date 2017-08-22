# frozen_string_literal: true

class PushNotification::FollowingMovesNewCar < PushNotification
  def message
    "#{source} no longer owns #{notifiable}"
  end

  def notifiable_image_url
    photo = notifiable.photos.sorted.first
    photo ? ix_refile_image_url(photo, :image) : nil
  end
end
