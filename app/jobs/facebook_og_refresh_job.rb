# frozen_string_literal: true

class FacebookOgRefreshJob < ApplicationJob
  queue_as :default

  def perform
    pending = User
              .where(fb_og_refreshed: false)
              .where.not(profile_thumbnail_id: nil)
    pending.each do |user|
      ProfileUploader.new(user).force_facebook_og_refresh
    end
  end
end
