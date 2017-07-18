class Model < ActiveRecord::Base
  include FriendlyId

  belongs_to :make
  has_many :trims, dependent: :destroy
  has_many :cars, dependent: :nullify

  friendly_id :name, scope: :make, use: %i[slugged scoped]

  validates :name, presence: true, uniqueness: { scope: :make_id, case_sensitive: false }

  scope :official, -> { where(official: true) }
  scope :sorted, -> { order(name: :asc) }
  scope :with_make_id, ->(id) { where(make_id: id) }

  def to_s
    "#{make} #{name}"
  end
end
