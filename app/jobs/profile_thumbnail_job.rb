class ProfileThumbnailJob < ActiveJob::Base
  queue_as :image_processing

  def perform(user_id)
    user = User.find_by(id: user_id)
    if user
      uploader = ProfileUploader.new(user)
      uploader.generate
    end
  end
end
