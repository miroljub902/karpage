class Video < ApplicationRecord
  INPUT_PREFIX = 'video-input'
  TEMP_PREFIX  = 'video-temp'
  FINAL_PREFIX = 'video'

  belongs_to :attachable, polymorphic: true

  enum status: {
    pending: 'pending', processing: 'processing', complete: 'complete', canceled: 'canceled', error: 'error'
  }

  def final_url(path)
    "https://s3.amazonaws.com/#{ENV.fetch('S3_BUCKET')}/#{path}"
  end
end
