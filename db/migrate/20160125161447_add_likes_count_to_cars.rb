# frozen_string_literal: true

class AddLikesCountToCars < ActiveRecord::Migration
  def change
    add_column :cars, :likes_count, :integer, null: false, default: 0
  end
end
