# frozen_string_literal: true

class Model < ActiveRecord::Base
  include FriendlyId

  belongs_to :make
  has_many :trims, dependent: :destroy
  has_many :cars, dependent: :nullify

  friendly_id :name, scope: :make, use: %i[slugged scoped]

  validates :name, presence: true, uniqueness: { scope: :make_id, case_sensitive: false }
  validates :make_id, presence: true

  scope :official, -> { where(official: true) }
  scope :official_or_with_id, ->(id) { where('models.official = ? OR models.id = ?', true, id) }
  scope :sorted, -> { order(name: :asc) }
  scope :with_make_id, ->(id) { where(make_id: id) }
  scope :has_year, ->(year) { year.present? ? distinct.joins(:trims).where(trims: { year: year }) : all }

  def to_s
    "#{make} #{name}"
  end
end
