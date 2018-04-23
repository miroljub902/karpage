class Video < ApplicationRecord
  INPUT_PREFIX = 'video-input'
  TEMP_PREFIX  = 'video-temp'
  FINAL_PREFIX = 'video'

  belongs_to :attachable, polymorphic: true

  enum status: {
    pending: 'pending', processing: 'processing', complete: 'complete', canceled: 'canceled', error: 'error'
  }

  before_update do
    if source_id_changed?
      self.status = Video.statuses[:pending]
      self.job_id = nil
      self.job_status = nil
      self.job_status_detail = nil
      self.urls = {}
    end
  end

  after_commit do
    VideoTranscodingJob.perform_later(id) if saved_change_to_attribute?(:source_id)
  end

  def final_url(path)
    "https://s3.amazonaws.com/#{ENV.fetch('S3_BUCKET')}/#{path}"
  end

  def thumb_url
    return unless (path = urls.dig('mp4', 'thumb'))
    "https://s3.amazonaws.com/#{ENV.fetch('S3_BUCKET')}/#{path}"
  end

  def s3_key_prefix
    "#{attachable_type.downcase}/" + Digest::MD5.hexdigest("#{attachable_id}/#{id}")
  end
end
