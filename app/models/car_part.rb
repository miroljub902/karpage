class CarPart < ActiveRecord::Base
  self.inheritance_column = '_no_sti'

  belongs_to :car
  has_one :photo, as: :attachable, dependent: :destroy

  accepts_nested_attributes_for :photo, allow_destroy: true

  validates :type, presence: true
end
