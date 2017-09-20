# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :business
  has_many :photos, as: :attachable, dependent: :destroy
end
