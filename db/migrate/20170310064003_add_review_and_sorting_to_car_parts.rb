# frozen_string_literal: true

class AddReviewAndSortingToCarParts < ActiveRecord::Migration
  def change
    add_column :car_parts, :review, :string
    add_column :car_parts, :sorting, :integer
    add_index :car_parts, :sorting
  end
end
