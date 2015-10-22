class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.crypto_provider Authlogic::CryptoProviders::BCrypt
    config.perishable_token_valid_for 3.hours
    config.merge_validates_format_of_email_field_options if: -> { identities.empty? || email.present? }
    config.merge_validates_format_of_login_field_options if: -> { identities.empty? || login.present? }
    config.merge_validates_length_of_login_field_options if: -> { identities.empty? || login.present? }
    config.merge_validates_length_of_password_field_options if: -> { identities.empty? || password.present? }
    config.merge_validates_confirmation_of_password_field_options if: -> { identities.empty? || password.present? }
  end

  has_many :identities, dependent: :delete_all
  has_many :cars, dependent: :destroy

  after_save :send_welcome_email, if: -> { email.present? && email_was.blank? }

  def self.find_by_login_or_email(login)
    User.find_by(login: login) || User.find_by(email: login)
  end

  def to_s
    name
  end

  def deliver_reset_password_instructions!
    reset_perishable_token!
    UserMailer.new(self).reset_password!
  end

  private

  def send_welcome_email
    UserMailer.new(self).welcome_email!
  end
end
