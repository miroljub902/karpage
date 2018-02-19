# frozen_string_literal: true

class UserSession < Authlogic::Session::Base
  # rubocop:disable Rails/DynamicFindBy
  find_by_login_method :find_by_login_or_email

  after_destroy :reset_user_access_token
  after_create :reset_user_access_token, unless: -> { access_token.present? }

  delegate :access_token, to: :user, allow_nil: true

  def self.from_facebook(token)
    session = new
    facebook = Koala::Facebook::API.new(token).get_object('me')
    identity = Identity.find_by(provider: 'facebook', uid: facebook['id'])
    session = create(identity.try(:user))
  rescue StandardError => e
    session.errors.add :base, "invalid Facebook token (#{e.message})"
    session
  end

  private

  def reset_user_access_token
    user.generate_access_token! if user.present? && !user.will_save_change_to_access_token?
  end
end
