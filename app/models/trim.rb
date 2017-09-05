# frozen_string_literal: true

class Trim < ActiveRecord::Base
  belongs_to :model
  has_one :make, through: :model
  has_many :cars, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: %i[model_id year], case_sensitive: false }
  validates :model_id, :year, presence: true

  scope :official, -> { where(official: true) }
  scope :official_or_with_id, ->(id) { where('trims.official = ? OR trims.id = ?', true, id) }
  scope :sorted, -> { order(name: :asc) }
  scope :with_make_id, ->(id) { joins(:model).where(models: { make_id: id }) }
  scope :with_model_id, ->(id) { where(model_id: id) }
  scope :with_year, ->(year) { year.present? ? distinct.where(year: year) : all }

  delegate :id, to: :make, prefix: :make, allow_nil: true

  def to_s
    name
  end
end
