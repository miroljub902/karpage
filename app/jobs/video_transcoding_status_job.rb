# frozen_string_literal: true

class VideoTranscodingStatusJob < ApplicationJob
  queue_as :default

  def perform
    Video.processing.each do |video|
      Video::UpdateTranscodingStatus.(video)
    end
  end
end
