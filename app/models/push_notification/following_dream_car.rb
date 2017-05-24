class PushNotification::FollowingDreamCar < PushNotification
  def message
    "#{source} added dream car"
  end

  def notifiable_image_url
    ix_refile_image_url notifiable, :image
  end
end
