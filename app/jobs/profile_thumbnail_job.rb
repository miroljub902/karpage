class ProfileThumbnailJob < ActiveJob::Base
  queue_as :image_processing

  def perform(user_id)
    user = User.find_by(id: user_id)
    uploader = ProfileUploader.new(user)
    uploader.profile_image_generator
  end
end
