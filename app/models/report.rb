# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true

  scope :users, -> { where(reportable_type: "User") }
  scope :cars, -> { where(reportable_type: "Car") }
  scope :posts, -> { where(reportable_type: "Post") }

  validates :reason, presence: true
end
