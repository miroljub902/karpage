# frozen_string_literal: true

class AddUpvotesCountToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :upvotes_count, :integer, null: false, default: 0
  end
end
