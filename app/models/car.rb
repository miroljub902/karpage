class Car < ActiveRecord::Base
  include FriendlyId

  belongs_to :user
  belongs_to :model
  has_one :make, through: :model
  has_many :photos, as: :attachable, dependent: :destroy

  friendly_id :slug_candidates, scope: :user, use: %i(slugged scoped)

  validates :year, numericality: true
  validates :car_model_name, presence: true
  validates_associated :model

  attr_accessor :make_name, :car_model_name
  before_validation :find_or_build_make_and_model

  def make_name
    @make_name.presence || make.try(:name)
  end

  def car_model_name
    @car_model_name.presence || model.try(:name)
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
    make = self.make || Make.find_by(slug: make_name.parameterize) || Make.create(name: make_name)
    self.model ||= (make.models.find_by(slug: car_model_name.parameterize) || make.models.new(name: car_model_name))
    true
  end

  def slug_candidates
    base = "#{year} #{make_name} #{car_model_name}"
    [base, *(2..10).map { |n| "#{base} #{n}"}]
  end
end
