class Model < ActiveRecord::Base
  include FriendlyId

  belongs_to :make
  has_many :cars, dependent: :nullify

  friendly_id :name, scope: :make, use: %i(slugged scoped)

  validates :name, presence: true, uniqueness: { scope: :make_id, case_sensitive: false }

  def to_s
    "#{make} #{name}"
  end
end
