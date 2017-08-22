# frozen_string_literal: true

class AddIndexesToTimestamps < ActiveRecord::Migration
  def change
    add_index :posts, :created_at
    add_index :follows, :created_at
    add_index :likes, :created_at
    add_index :comments, :created_at
  end
end
