require 'imgix_refile_helper'

class PushNotification
  include ImgixRefileHelper

  attr_reader :notification

  delegate :user, :notifiable, :source, to: :notification

  def self.for(notification)
    "PushNotification::#{notification.type.classify}".constantize.new(notification)
  end

  def initialize(notification)
    @notification = notification
  end

  def push!
    return mark_as_sent! unless device_token.present? && notifiable.present?

    response = make_http_request!

    if response.code == '200'
      notification.update_attributes sent_at: Time.zone.now, status_message: nil
    else
      notification.update_attributes status_message: response.body
    end
  end

  def image_url
    source.avatar ? ix_refile_image_url(source, :avatar) : nil
  end

  def notifiable_id
    notifiable.id
  end

  def related_id
    source_id
  end

  def related_type
    notification.source_type
  end

  def source_id
    source.to_param
  end

  private

  def mark_as_sent!
    notification.update_attributes sent_at: Time.zone.now, status_message: 'No device token present'
  end

  def make_http_request!
    uri = URI.parse('https://onesignal.com/api/v1/notifications')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path,
                                  'Content-Type'  => 'application/json;charset=utf-8',
                                  'Authorization' => "Basic #{ENV.fetch('ONESIGNAL_API_KEY')}")
    request.body = params.as_json.to_json
    http.request request
  end

  def device_token
    @_device_token ||= (user.device_info || {})['user_id'].presence
  end

  def params
    {
      app_id: ENV.fetch('ONESIGNAL_APP_ID'),
      contents: { en: message },
      include_player_ids: [device_token],
      data: metadata
    }
  end

  def metadata
    {
      notification_id: notification.id,
      notification_type: notification.type,
      notifiable_id: notifiable_id,
      source_type: notification.source_type,
      source_id: source_id,
      related_type: related_type,
      related_id: related_id,
      created_at: notification.created_at,
      image_url: image_url,
      notifiable_image_url: notifiable_image_url
    }
  end
end
