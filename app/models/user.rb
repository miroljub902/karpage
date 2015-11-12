class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.crypto_provider Authlogic::CryptoProviders::BCrypt
    config.perishable_token_valid_for 3.hours
    config.merge_validates_format_of_email_field_options if: -> { identities.empty? || email.present? }
    config.merge_validates_format_of_login_field_options if: -> { identities.empty? || login.present? || login_was.present? }
    config.merge_validates_length_of_login_field_options if: -> { identities.empty? || login.present? || login_was.present? }
    config.merge_validates_length_of_password_field_options if: -> { identities.empty? && password.present? }
    config.merge_validates_confirmation_of_password_field_options if: -> { identities.empty? && password.present? }
  end

  attachment :avatar
  attachment :profile_background

  has_many :identities, dependent: :delete_all
  has_many :cars, dependent: :destroy
  has_many :singles, class_name: 'Photo', as: :attachable, dependent: :destroy
  has_many :dream_cars, -> { where(photo_type: 'dream-car') }, class_name: 'Photo', as: :attachable
  has_one :next_car, -> { where(photo_type: 'next-car') }, class_name: 'Photo', as: :attachable
  has_many :comments, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :car_comments, through: :cars, source: :comments

  after_save :send_welcome_email, if: -> { email.present? && email_was.blank? }

  scope :search, -> (term) {
    like = %w(name login description twitter_uid location).map { |column| "#{column} ILIKE :term" }
    where like.join(' OR '), term: "%#{term}%"
  }

  # validates

  def self.find_by_login_or_email(login)
    User.find_by(login: login) || User.find_by(email: login)
  end

  def incomplete_profile?
    login.blank? || email.blank?
  end

  def to_param
    login.presence || id
  end

  def to_s
    name.to_s
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
