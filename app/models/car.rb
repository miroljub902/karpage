# rubocop:disable Lint/AmbiguousBlockAssociation
class Car < ActiveRecord::Base
  include FriendlyId
  include FeaturedOrdering

  belongs_to :user, counter_cache: true
  belongs_to :model
  has_one :make, through: :model
  has_many :photos, as: :attachable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :delete_all
  has_many :parts, -> { sorted }, class_name: 'CarPart', dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :delete_all

  accepts_nested_attributes_for :photos, allow_destroy: true
  accepts_nested_attributes_for :parts, allow_destroy: true

  friendly_id :slug_candidates, scope: :user, use: %i(slugged scoped)

  validates :year, numericality: true
  validates :make_name, :car_model_name, presence: true
  validates_associated :model
  validate :validate_current_past_first, on: :create

  attr_accessor :make_name, :car_model_name
  before_validation :find_or_build_make_and_model
  after_create :resort_first
  after_update -> { @sorting_changed = sorting_changed? }
  after_save :update_user_profile_thumbnail

  attr_reader :sorting_changed
  # Do this in after commit to avoid deadlocks:
  after_commit :resort_all, if: -> { sorting_changed }, on: :update

  scope :popular, -> { order(hits: :desc) }
  scope :featured, -> { where.not(featured_order: nil).order(featured_order: :asc) }
  scope :sorted, -> { order(:sorting) }
  scope :has_photos, -> { distinct.joins(:photos) }
  scope :current, -> { where(current: true) }
  scope :owner_has_login, -> { joins(:user).where.not(users: { login: '' }).where.not(users: { login: nil }) }
  scope :simple_search, ->(term, lat, lng) {
    year = term.to_i.to_s == term.strip ? term.to_i : nil
    term = term.to_s.split(' ').map(&:strip).join('%')
    year_condition = "cars.year = #{year} OR" if year
    scope = joins(:make, :user)
            .where("users.name ILIKE :term OR #{year_condition} cars.slug ILIKE :term OR makes.name ILIKE :term OR models.name ILIKE :term", term: "%#{term}%", year: term.to_i)
    if lat.present? && lng.present?
      meters = 20 * 1600 # (20 miles)
      scope = scope.where("ST_DWithin(point, ST_GeogFromText('SRID=4326;POINT(#{lng.to_f} #{lat.to_f})'), #{meters})")
    end
    scope
  }
  scope :not_blocked, ->(user) {
    if user
      joins(:user).where.not(users: { id: user.blocks.select(:blocked_user_id) })
    else
      all
    end
  }

  concerning :Notifications do
    included do
      after_create -> { notify_followers :following_new_car }, if: :current?
      after_create -> { notify_followers :following_new_first_car }, if: :first?
      after_create -> { notify_followers :following_new_past_car }, if: :past?
      after_update -> { notify_followers :following_moves_new_car }, if: -> { past? && current_was }
    end

    def notify_followers(notification)
      type = Notification.types[notification]
      user.followers.each do |follower|
        Notification.belay_create user: follower, type: type, notifiable: self, source: user
      end
    end
  end

  def toggle_like!(user)
    if (like = likes.find_by(user: user))
      like.destroy
    else
      likes.create! user: user
    end
  end

  def make_name
    @make_name.nil? ? make.try(:name) : @make_name
  end

  def car_model_name
    @car_model_name.nil? ? model.try(:name) : @car_model_name
  end

  def to_s
    full_name
  end

  def full_name
    "#{year} #{model}"
  end

  def past=(_value)
    super.tap do
      self.current = false if past === true
    end
  end

  private

  def validate_current_past_first
    if first && current
      errors.add :base, "Car cannot be both first and current"
    elsif first && past
      errors.add :base, "Car cannot be both first and past"
    elsif past && current
      errors.add :base, "Car cannot be both past and current"
    end
  end

  def resort_first
    return unless current? || past?
    update_column :sorting, -1
    scope = self.class.where(user: user)
    scope = current? ? scope.where(current: true) : scope.where(past: true)
    scope.update_all 'sorting = sorting + 1'
  end

  # This can't happen inside same transaction as car update or deadlocks can occur
  def resort_all
    return unless current? || past?
    scope = self.class.where(user: user).where('sorting >= ?', sorting).where.not(id: id)
    scope = current? ? scope.where(current: true) : scope.where(past: true)
    scope.update_all 'sorting = sorting + 1'
  end

  def find_or_build_make_and_model
    # Set make from existing make name or create it
    unless @make_name.nil?
      self.make = Make.find_by(slug: @make_name.parameterize) || Make.create(name: @make_name)
    end

    unless @car_model_name.nil? || make.nil?
      self.model = make.models.find_by(slug: @car_model_name.parameterize) || make.models.new(name: @car_model_name)
    end

    true
  end

  def update_user_profile_thumbnail
    ProfileThumbnailJob.perform_later user_id
  end

  def slug_candidates
    base = "#{year} #{make_name} #{car_model_name}"
    [base, *(2..10).map { |n| "#{base} #{n}"}]
  end
end
