# frozen_string_literal: true

class Identity < ApplicationRecord
  belongs_to :user

  validates :uid, uniqueness: { scope: %i[user_id provider] }

  # rubocop:disable Metrics/AbcSize
  def self.from_omniauth(auth)
    Identity.where(auth.to_h.slice('provider', 'uid')).first_or_initialize.tap do |identity|
      identity.oauth_token = auth.credentials.token
      identity.oauth_expires_at = Time.zone.at(auth.credentials.expires_at)
      identity.user ||= User.new
      identity.user.identities = [identity] if identity.user.identities.empty?
      identity.user.name ||= auth.info.name
      identity.user.email ||= auth.info.email
      # TODO: Pull avatar
      identity.save!
    end
  end
end
