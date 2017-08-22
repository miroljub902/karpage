# frozen_string_literal: true

class Make < ActiveRecord::Base
  include FriendlyId

  has_many :models, dependent: :destroy

  friendly_id :name, use: :slugged

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :official, -> { where(official: true) }
  scope :sorted, -> { order(name: :asc) }
  scope :has_year, ->(year) { year.present? ? distinct.joins(models: :trims).where(trims: { year: year }) : all }

  def to_s
    name
  end
end
