# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Car < ActiveRecord::Base
  include FriendlyId
  include FeaturedOrdering
  include UniqueViolationGuard

  self.inheritance_column = '_no_sti'

  enum type: {
    first_car: 'first_car',
    current_car: 'current_car',
    past_car: 'past_car',
    next_car: 'next_car'
  }

  belongs_to :user, counter_cache: true
  belongs_to :trim
  belongs_to :model
  has_one :make, through: :model
  has_many :photos, as: :attachable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :delete_all
  has_many :parts, -> { sorted }, class_name: 'CarPart', dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :delete_all

  accepts_nested_attributes_for :photos, allow_destroy: true
  accepts_nested_attributes_for :parts, allow_destroy: true

  friendly_id :slug_candidates, scope: :user, use: %i[slugged scoped]

  validates :year, numericality: { less_than: 9999, greater_than_or_equal_to: 1885 }
  validates :make_id, :model_id, presence: true
  validates :type, inclusion: { in: types.values, message: 'Invalid car type' }
  validates :description, length: { maximum: 2700 }

  attr_accessor :make_name, :car_model_name
  before_validation :find_or_build_make_and_model
  before_create -> { self.sorting = (self.class.where(user: user).pluck('MAX(sorting)').first || -1) + 1 }
  after_update -> { @sorting_changed = sorting_changed? }
  after_save :update_user_profile_thumbnail

  attr_reader :sorting_changed
  # Do this in after commit to avoid deadlocks:
  after_commit :resort_all, if: -> { sorting_changed }, on: :update

  scope :popular, -> { order(hits: :desc) }
  scope :featured, -> { where.not(featured_order: nil).order(featured_order: :asc) }
  scope :sorted, -> { order(:sorting) }
  scope :has_photos, -> { distinct.joins(:photos) }
  scope :owner_has_login, -> { joins(:user).where.not(users: { login: '' }).where.not(users: { login: nil }) }
  scope :simple_search, ->(term, lat, lng) {
    year = term.to_i.to_s == term.strip ? term.to_i : nil
    term = term.to_s.split(' ').map(&:strip).join('%')
    year_condition = "cars.year = #{year} OR" if year
    query = <<-SQL
      users.name ILIKE :term
      OR #{year_condition} cars.slug ILIKE :term OR makes.name ILIKE :term OR models.name ILIKE :term
    SQL
    scope = joins(:make, :user).where(query, term: "%#{term}%", year: term.to_i)
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

  scope :standard, -> {
    where(type: types.slice(:current_car, :past_car, :first_car).values)
  }

  concerning :Notifications do
    included do
      after_create -> { notify_followers :following_new_car }, if: :current_car?
      after_create -> { notify_followers :following_new_first_car }, if: :first_car?
      after_create -> { notify_followers :following_new_past_car }, if: :past_car?
      after_update -> { notify_followers :following_moves_new_car }, if: -> {
        past_car? && type_was == Car.types[:current_car]
      }
      after_create -> { notify_followers :following_next_car }, if: :next_car?
    end

    def notify_followers(notification)
      type = Notification.types[notification]
      user.followers.each do |follower|
        Notification.belay_create user: follower, type: type, notifiable: self, source: user
      end
    end
  end

  def type=(value)
    # Override so an ArgumentError is not raised on invalid types, handle through validation instead
    super if self.class.types.values.include?(value)
    value
  end

  def toggle_like!(user)
    if (like = likes.find_by(user: user))
      like.destroy
    else
      likes.create! user: user
    end
  end

  def make_id
    make.try :id
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

  private

  # This can't happen inside same transaction as car update or deadlocks can occur
  def resort_all
    return unless current_car? || past_car?
    scope = self.class.where(user: user).where('sorting >= ?', sorting).where.not(id: id)
    scope = current_car? ? scope.current_car : scope.past_car
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
    [base, *(2..10).map { |n| "#{base} #{n}" }]
  end
end
