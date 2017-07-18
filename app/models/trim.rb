class Trim < ActiveRecord::Base
  include FriendlyId

  belongs_to :model
  has_many :cars, dependent: :nullify

  friendly_id :name, scope: :model, use: %i[slugged scoped]

  validates :name, presence: true, uniqueness: { scope: :model_id, case_sensitive: false }

  scope :official, -> { where(official: true) }
  scope :sorted, -> { order(name: :asc) }
  scope :with_make_id, ->(id) { joins(:model).where(models: { make_id: id }) }
  scope :with_model_id, ->(id) { where(model_id: id) }

  def to_s
    name
  end
end
