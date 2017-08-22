# frozen_string_literal: true

class PushNotification::YourPostLike < PushNotification
  def message
    "#{source} liked your post"
  end

  def notifiable_image_url
    notifiable.photo ? ix_refile_image_url(notifiable, :photo) : nil
  end
end
