# frozen_string_literal: true

class ProfileThumbnailJob < ActiveJob::Base
  queue_as :image_processing

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user
    uploader = ProfileUploader.new(user)
    uploader.generate_and_save
  end
end
