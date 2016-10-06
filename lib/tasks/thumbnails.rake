namespace :thumbnails do
  task generate: :environment do
    User.find_each do |user|
      uploader = ProfileUploader.new(user)
      uploader.profile_image_generator
    end
  end
end
