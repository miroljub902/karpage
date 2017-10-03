# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class User < ApplicationRecord
  include FeaturedOrdering
  include UniqueViolationGuard

  strip_attributes allow_empty: true

  acts_as_authentic do |config|
    config.crypto_provider Authlogic::CryptoProviders::BCrypt
    config.perishable_token_valid_for 3.hours
    config.merge_validates_format_of_email_field_options if: -> { identities.empty? || email.present? }
    config.merge_validates_format_of_login_field_options(
      with: /\A\w[.\w+_]+\z/,
      if: -> { identities.empty? || login.present? || login_in_database.present? },
      message: 'should use only letters numbers and ._ please'
    )
    config.merge_validates_length_of_login_field_options if: -> {
      identities.empty? || login.present? || login_in_database.present?
    }
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
  has_one :next_car, -> { where(type: Car.types[:next_car]) }, class_name: 'Car'
  has_many :comments, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :car_comments, through: :cars, source: :comments
  has_many :follows, dependent: :destroy
  has_many :follows_by, class_name: 'Follow', foreign_key: 'followee_id'
  has_many :followers, through: :follows_by, source: :user
  has_many :followees, through: :follows
  has_many :blocks, dependent: :delete_all
  has_one :business, dependent: :destroy
  has_many :notifications, dependent: :delete_all
  has_many :notifications_as_source, as: :source, class_name: 'Notification', dependent: :delete_all
  has_many :reports_reported, class_name: 'Report', dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy

  accepts_nested_attributes_for :dream_cars, allow_destroy: true

  validates_associated :identities

  before_create :generate_access_token
  after_save :send_welcome_email, if: -> { email.present? && email_before_last_save.blank? }
  after_save -> { ProfileThumbnailJob.perform_later(id) },
             if: -> {
               changes_to_save.keys.any? do |attr|
                 %w[login name avatar_id description profile_background_id].include?(attr)
               end
             }

  scope :by_cars_owned, -> { cars_count.order('filtered_cars_count DESC') }

  scope :cars_count, -> {
    select('users.*, COUNT(cars_counter.id) AS filtered_cars_count')
      .joins(
        <<-SQL
        LEFT OUTER JOIN cars cars_counter ON cars_counter.user_id = users.id
          AND cars_counter.type <> '#{Car.types[:next_car]}'
        SQL
      )
      .group('users.id')
  }

  scope :simple_search, ->(term, lat, lng, radius_in_km = 32_000) {
    like = %w[name login description link location].map { |column| "#{table_name}.#{column} ILIKE :term" }
    scope = all
    scope = scope.where(like.join(' OR '), term: "%#{term.to_s.strip}%") if term.present?

    if lat.present? && lng.present?
      # 20 miles default
      meters = radius_in_km.blank? ? 32_000 : radius_in_km.to_f * 1000
      scope = scope.where("ST_DWithin(point, ST_GeogFromText('SRID=4326;POINT(#{lng.to_f} #{lat.to_f})'), #{meters})")
    end
    scope
  }

  scope :not_blocked, ->(user) {
    if user
      where.not(users: { id: user.blocks.select(:blocked_user_id) })
    else
      all
    end
  }

  scope :with_login_or_email, ->(login_or_email) {
    where('login = :l OR email = :l', l: login_or_email)
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
        identities << identity
      else
        errors.add :facebook_token, :taken
      end
    rescue StandardError => e
      errors.add :facebook_token, "invalid Facebook token (#{e.message})"
    end
  end

  # rubocop:disable Metrics/BlockLength
  concerning :PushNotifications do
    included do
      after_save -> {
        self.class
            .where('device_info @> ?', %({"user_id": "#{device_info['user_id']}"}))
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

    # rubocop:disable Style/DoubleNegation
    def push_settings
      DEFAULT_PUSH_SETTINGS.each_with_object({}) do |(setting, default), settings|
        value = self[:push_settings].key?(setting) ? self[:push_settings][setting] : default
        settings[setting] = value == !!value ? value : value == 'true'
      end
    end

    def push_setting?(setting)
      push_settings[setting]
    end
  end

  concerning :DemoAccount do
    included do
      %i[password email login device_info].each do |method|
        define_method "#{method}=" do |value|
          super(value) if new_record? || !demo_account?
        end
      end

      def demo_account?
        login.to_s.casecmp('demo').zero?
      end
    end
  end

  concerning :NormalizeAttributes do
    included do
      before_save -> do
        self.instagram_id = instagram_id.delete('@') if instagram_id
      end

      def link=(value)
        self[:link] = %r{^https?:\/\/}i.match(value) || value.to_s.strip.empty? ? value : "http://#{value}"
      end
    end
  end

  def friends
    User
      .joins('INNER JOIN follows ON follows.user_id = users.id OR follows.followee_id = users.id')
      .where('follows.user_id = :id OR follows.followee_id = :id', id: id)
      .where.not(id: id)
      .distinct
  end

  def cars_count
    self['filtered_cars_count'] || (self['cars_count'] - cars.next_car.count)
  end

  def friends_posts
    Post.where(user_id: followees.select(:id))
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
    loop do
      self.access_token = SecureRandom.hex(32)
      break unless User.where(access_token: access_token).exists?
    end
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
