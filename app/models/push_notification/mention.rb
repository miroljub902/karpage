# frozen_string_literal: true

class PushNotification::Mention < PushNotification
  def message
    "#{source} mentioned you on a #{notifiable.class.model_name.human.downcase}"
  end

  def notifiable_image_url
    case notifiable
    when Car
      photo = notifiable.photos.sorted.first
      photo ? ix_refile_image_url(photo, :image) : nil
    when Post
      notifiable.photo ? ix_refile_image_url(notifiable, :photo) : nil
    when Comment
      notifiable.user.avatar ? ix_refile_image_url(notifiable.user, :avatar) : nil
    end
  end
end
