class Car < ActiveRecord::Base
  include FriendlyId
  include FeaturedOrdering

  belongs_to :user, counter_cache: true
  belongs_to :model
  has_one :make, through: :model
  has_many :photos, as: :attachable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :delete_all

  accepts_nested_attributes_for :photos

  friendly_id :slug_candidates, scope: :user, use: %i(slugged scoped)

  validates :year, numericality: true
  validates :make_name, :car_model_name, presence: true
  validates_associated :model

  attr_accessor :make_name, :car_model_name
  before_validation :find_or_build_make_and_model

  scope :popular, -> { order(hits: :desc) }
  scope :featured, -> { where.not(featured_order: nil).order(featured_order: :asc) }
  scope :has_photos, -> { distinct.joins(:photos) }
  scope :simple_search, -> (term) {
    year = term.to_i.to_s == term.strip ? term.to_i : nil
    year_condition = "cars.year = #{year} OR" if year
    joins(:make, :user)
      .where("users.name ILIKE :term OR #{year_condition} cars.slug ILIKE :term OR makes.name ILIKE :term OR models.name ILIKE :term", term: "%#{term.to_s.strip}%", year: term.to_i)
  }

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

  def slug_candidates
    base = "#{year} #{make_name} #{car_model_name}"
    [base, *(2..10).map { |n| "#{base} #{n}"}]
  end
end
