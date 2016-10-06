class ProfilesWorker
  include Sidekiq::Worker

  def perform(object)
    uploader = ProfileUploader.new(object)
    uploader.profile_image_generator
  end
end
