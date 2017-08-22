# frozen_string_literal: true

class Product < ActiveRecord::Base
  belongs_to :business
  has_many :photos, as: :attachable, dependent: :destroy
end
