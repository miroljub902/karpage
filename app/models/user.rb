class User < ActiveRecord::Base
  include FeaturedOrdering

  strip_attributes allow_empty: true

  acts_as_authentic do |config|
    config.crypto_provider Authlogic::CryptoProviders::BCrypt
    config.perishable_token_valid_for 3.hours
    config.merge_validates_format_of_email_field_options if: -> { identities.empty? || email.present? }
    config.merge_validates_format_of_login_field_options(
      with: /\A\w[.\w+\-_]+\z/,
      if: -> { identities.empty? || login.present? || login_was.present? },
      message: 'should use only letters numbers and .-_ please'
    )
    config.merge_validates_length_of_login_field_options if: -> { identities.empty? || login.present? || login_was.present? }
    config.merge_validates_length_of_password_field_options if: -> { identities.empty? && password.present? }
    config.merge_validates_confirmation_of_password_field_options if: -> { identities.empty? && password.present? }
  end

  attachment :avatar, type: :image
  attachment :profile_background, type: :image
  attachment :profile_thumbnail, type: :image

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
  has_many :blocks, dependent: :delete_all
  has_one :business, dependent: :destroy
  has_many :notifications, dependent: :delete_all

  accepts_nested_attributes_for :dream_cars, :next_car, allow_destroy: true

  validates_associated :identities
  validates :email, uniqueness: true, allow_blank: true

  before_create :generate_access_token
  after_save :send_welcome_email, if: -> { email.present? && email_was.blank? }
  after_save -> { ProfileThumbnailJob.perform_later(id) },
    if: -> { changes.keys.any? { |attr| %w(login name avatar_id description profile_background_id).include?(attr) } }

  scope :by_cars_owned, -> { order(cars_count: :desc) }

  scope :simple_search, -> (term) {
    like = %w(name login description link location).map { |column| "#{column} ILIKE :term" }
    where like.join(' OR '), term: "%#{term.to_s.strip}%"
  }

  scope :not_blocked, -> (user) {
    if user
      where.not(users: { id: user.blocks.select(:blocked_user_id) })
    else
      all
    end
  }

  def self.find_by_login_or_email(login)
    normalized = login.to_s.strip.downcase
    User.find_by(login: normalized) || User.find_by(email: normalized)
  end

  concerning :Facebook do
    included do
      attr_accessor :facebook_token
      validate :validate_facebook_token, if: -> { facebook_token.present? }
    end

    def validate_facebook_token
      facebook = Koala::Facebook::API.new(facebook_token).get_object('me')
      identity = Identity.find_or_initialize_by provider: 'facebook', uid: facebook['id']
      if identity.new_record?
        self.identities << identity
      else
        errors.add :facebook_token, :taken
      end
    rescue => e
      errors.add :facebook_token, "invalid Facebook token (#{e.message})"
    end
  end

  concerning :PushNotifications do
    included do
      after_save -> {
        self.class
            .where('device_info @> ?', %Q({"user_id": "#{self.device_info['user_id']}"}))
            .where.not(id: id).update_all device_info: nil
      }, if: -> { (device_info || {}).key?('user_id') }
    end

    DEFAULT_PUSH_SETTINGS = {
      Notification.types[:your_car_like] => true,
      Notification.types[:your_car_comment] => true,
      Notification.types[:your_post_like] => true,
      Notification.types[:your_post_comment] => true,
      Notification.types[:new_follower] => true,
      Notification.types[:following_new_car] => true,
      Notification.types[:following_new_first_car] => true,
      Notification.types[:following_new_past_car] => true,
      Notification.types[:following_moves_new_car] => true,
      Notification.types[:following_next_car] => true,
      Notification.types[:following_dream_car] => true,
      Notification.types[:following_new_post] => true
    }.freeze

    def push_settings
      DEFAULT_PUSH_SETTINGS.each_with_object({}) do |(setting, default), settings|
        value = self[:push_settings].key?(setting) ? self[:push_settings][setting] : default
        settings[setting] = value
      end
    end

    def push_setting?(setting)
      push_settings[setting]
    end
  end

  def friends
    User
      .joins('INNER JOIN follows ON follows.user_id = users.id OR follows.followee_id = users.id')
      .where('follows.user_id = :id OR follows.followee_id = :id', id: id)
      .where.not(id: id)
      .distinct
  end

  def friends_posts
    Post.where(user_id: followees.select(:id))
  end

  def link=(value)
    self[:link] = (/^https?:\/\//i.match(value) || value.to_s.strip.empty?) ? value : "http://#{value}"
  end

  def follow!(user)
    follows.find_or_create_by(followee_id: user.id)
  end

  def unfollow!(user)
    follows.where(followee_id: user.id).destroy_all
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

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex(32)
    end while User.where(access_token: access_token).exists?
  end

  def generate_access_token!
    generate_access_token
    save!
  rescue ActiveRecord::RecordNotUnique => e
    # This sometimes happens on the API, somehow bypassing the uniqueness validation so rescue here
    # Parse "DETAIL: Key (<attribute>)=(<value>) already exists"
    attribute = e.message.match(/Key \((.*?)\)=.+already exists/m)[1]
    errors.add attribute, :taken
  rescue ActiveRecord::RecordInvalid => _e
    errors.add :base, 'Invalid login'
  end

  private

  def send_welcome_email
    UserMailer.new(self).welcome_email!
  end
end
