# frozen_string_literal: true

class Business < ActiveRecord::Base
  belongs_to :user
  has_many :products, dependent: :destroy

  validates :name, presence: true
end
