# frozen_string_literal: true

class VideoTranscodingJob < ApplicationJob
  queue_as :default

  def perform(video_id)
    return unless (video = Video.find_by(id: video_id))
    Video::Transcode.(video)
  end
end
