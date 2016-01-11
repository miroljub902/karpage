class Car < ActiveRecord::Base
  include FriendlyId

  belongs_to :user, counter_cache: true
  belongs_to :model
  has_one :make, through: :model
  has_many :photos, as: :attachable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  accepts_nested_attributes_for :photos

  friendly_id :slug_candidates, scope: :user, use: %i(slugged scoped)

  validates :year, numericality: true
  validates :make_name, :car_model_name, presence: true
  validates_associated :model

  attr_accessor :make_name, :car_model_name
  before_validation :find_or_build_make_and_model

  scope :popular, -> { order(hits: :desc) }
  scope :has_photos, -> { distinct.joins(:photos) }
  scope :simple_search, -> (term) {
    joins(:make)
      .where('cars.slug ILIKE :term OR description ILIKE :term OR makes.name ILIKE :term OR models.name ILIKE :term', term: "%#{term}%")
  }

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
