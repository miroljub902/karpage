class PushNotification::FollowingNextCar < PushNotification
  def message
    "#{source} added a next car"
  end

  def notifiable_image_url
    ix_refile_image_url notifiable, :image
  end
end