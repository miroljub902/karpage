# frozen_string_literal: true

class VideoDecorator < Draper::Decorator
  delegate :content_tag, :safe_join, to: :h

  delegate_all

  def poster_url
    s3_url urls['webm']['thumb']
  end

  def video_sources
    safe_join(urls.map do |type, urls|
      content_tag :source, '', src: s3_url(urls['source']), type: "video/#{type}"
    end)
  end

  private

  def s3_url(key)
    "https://s3.amazonaws.com/#{ENV.fetch('S3_BUCKET')}/#{key}"
  end
end
