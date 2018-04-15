# frozen_string_literal: true

class CarPart < ApplicationRecord
  include UrlNormalizer

  self.inheritance_column = '_no_sti'

  belongs_to :car, inverse_of: :parts
  has_one :photo, as: :attachable, dependent: :destroy

  accepts_nested_attributes_for :photo, allow_destroy: true

  scope :sorted, -> { order(sorting: :asc) }

  validates :type, presence: true

  before_save do
    self.sorting ||= (car.parts.maximum(:sorting) || -1) + 1
  end

  normalize_url :link
end
