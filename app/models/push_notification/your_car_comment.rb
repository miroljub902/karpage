class PushNotification::YourCarComment < PushNotification
  def message
    body = notifiable.body.truncate(20)
    "#{source} commented on your #{notifiable.commentable}: #{body}"
  end

  def notifiable_image_url
    photo = notifiable.commentable.photos.sorted.first
    photo ? ix_refile_image_url(photo, :image) : nil
  end

  def related_id
    notifiable.commentable_id
  end

  def related_type
    'Car'
  end
end
