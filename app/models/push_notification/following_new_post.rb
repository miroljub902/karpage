class PushNotification::FollowingNewPost < PushNotification
  def message
    "#{source} has a new post"
  end

  def notifiable_image_url
    notifiable.photo ? ix_refile_image_url(notifiable.photo, :image) : nil
  end
end
