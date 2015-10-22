class Make < ActiveRecord::Base
  include FriendlyId

  has_many :models, dependent: :destroy

  friendly_id :name, use: :slugged

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def to_s
    name
  end
end
