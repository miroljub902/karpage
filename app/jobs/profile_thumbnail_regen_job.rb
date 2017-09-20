# frozen_string_literal: true

class ProfileThumbnailRegenJob < ApplicationJob
  queue_as :default

  def perform
    pending = User
              .where(profile_thumbnail_id: nil)
              .where('created_at < ?', 1.day.ago)
              .order(created_at: :desc)
              .limit(20)
    pending.pluck(:id).each do |user_id|
      ProfileThumbnailJob.perform_later user_id
    end
  end
end
