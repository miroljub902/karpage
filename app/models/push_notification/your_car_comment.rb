class PushNotification::YourCarComment < PushNotification
  def message
    body = notifiable.body.truncate(20)
    "#{source} commented on your #{notifiable.commentable}: #{body}"
  end

  def notifiable_image_url
    photo = notifiable.commentable.photos.sorted.first
    photo ? ix_refile_image_url(photo, :image) : nil
  end
end
