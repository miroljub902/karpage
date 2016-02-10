class UserSession < Authlogic::Session::Base
  find_by_login_method :find_by_login_or_email

  after_destroy :reset_user_access_token
  after_create :reset_user_access_token

  delegate :access_token, to: :user, allow_nil: true

  def self.from_facebook(token)
    session = new
    facebook = Koala::Facebook::API.new(token).get_object('me')
    identity = Identity.find_by(provider: 'facebook', uid: facebook['id'])
    session = create(identity.try(:user))
  rescue => e
    session.errors.add :base, "invalid Facebook token (#{e.message})"
    session
  end

  private

  def reset_user_access_token
    user.generate_access_token! if user && !user.access_token_changed?
  end
end
