class User < ActiveRecord::Base
  include FeaturedOrdering

  acts_as_authentic do |config|
    config.crypto_provider Authlogic::CryptoProviders::BCrypt
    config.perishable_token_valid_for 3.hours
    config.merge_validates_format_of_email_field_options if: -> { identities.empty? || email.present? }
    config.merge_validates_format_of_login_field_options(
      with: /\A\w[\w+\-_@ ]+\z/,
      if: -> { identities.empty? || login.present? || login_was.present? }
    )
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
  has_many :follows
  has_many :follows_by, class_name: 'Follow', foreign_key: 'followee_id'
  has_many :followers, through: :follows_by, source: :user
  has_many :followees, through: :follows

  after_save :send_welcome_email, if: -> { email.present? && email_was.blank? }

  scope :by_cars_owned, -> { order(cars_count: :desc) }

  scope :simple_search, -> (term) {
    like = %w(name login description link location).map { |column| "#{column} ILIKE :term" }
    where like.join(' OR '), term: "%#{term}%"
  }

  def self.find_by_login_or_email(login)
    User.find_by(login: login) || User.find_by(email: login)
  end

  def friends_posts
    Post.where(user_id: followees.select(:id))
  end

  def link=(value)
    self[:link] = (/^https?:\/\//i.match(value) || value.strip.empty?) ? value : "http://#{value}"
  end

  def follow!(user)
    follows.find_or_create_by(followee_id: user.id)
  end

  def unfollow!(user)
    follows.where(followee_id: user.id).delete_all
  end

  def following?(user)
    follows.where(followee_id: user.id).exists?
  end

  def incomplete_profile?
    login.blank? || email.blank?
  end

  def to_param
    login.presence || id.to_s
  end

  def to_s
    name.to_s.presence || login.to_s
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
