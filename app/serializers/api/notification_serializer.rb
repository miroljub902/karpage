class Api::NotificationSerializer < ActiveModel::Serializer
  attributes %i[id type notifiable_id notifiable_type source_id source_type message created_at]
  attributes :image_url, :notifiable_image_url

  def image_url
    push_object.image_url
  end

  def notifiable_image_url
    push_object.notifiable_image_url
  end

  private

  def push_object
    @_push_object ||= PushNotification.for(object)
  end
end
