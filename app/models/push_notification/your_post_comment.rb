class PushNotification::YourPostComment < PushNotification
  def message
    "#{source} commented on your post"
  end

  def notifiable_image_url
    notifiable.commentable.photo ? ix_refile_image_url(notifiable.commentable, :photo) : nil
  end

  def notifiable_id
    notifiable.commentable_id
  end
end
