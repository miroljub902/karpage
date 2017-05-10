class PushNotification::NewFollower < PushNotification
  def message
    "#{source} started following you"
  end

  def notifiable_image_url
    user.avatar ? ix_refile_image_url(user, :avatar) : nil
  end

  def notifiable_id
    notifiable.user_id
  end
end
