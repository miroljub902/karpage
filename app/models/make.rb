class Make < ActiveRecord::Base
  include FriendlyId

  has_many :models, dependent: :destroy

  friendly_id :name, use: :slugged

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :official, -> { where(official: true) }
  scope :sorted, -> { order(name: :asc) }

  def to_s
    name
  end
end
