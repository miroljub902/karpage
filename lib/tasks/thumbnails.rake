namespace :thumbnails do
  task generate: :environment do
    User.find_each do |user|
      uploader = ProfileUploader.new(user)
      uploader.profile_image_generator
    end
  end

  task schedule: :environment do
    User.pluck(:id).each do |id|
      ProfileThumbnailJob.perform_later(id)
    end
  end
end
