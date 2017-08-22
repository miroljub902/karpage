# frozen_string_literal: true

namespace :thumbnails do
  task :generate, %i[user_id inline] => :environment do |_t, args|
    users = args[:user_id] ? User.where(id: args[:user_id]) : User.all
    users.find_each do |user|
      uploader = ProfileUploader.new(user)
      uploader.generate_and_save(inline: args[:inline].present?)
    end
  end

  task schedule: :environment do
    User.pluck(:id).each do |id|
      ProfileThumbnailJob.perform_later(id)
    end
  end
end
