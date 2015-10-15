class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.crypto_provider Authlogic::CryptoProviders::BCrypt
  end

  validates :email, :login, presence: true

  def self.find_by_login_or_email(login)
    User.find_by(login: login) || User.find_by(email: login)
  end
end
