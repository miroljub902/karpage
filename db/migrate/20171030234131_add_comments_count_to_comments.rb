# frozen_string_literal: true

class AddCommentsCountToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :comments_count, :integer, null: false, default: 0
    add_index :comments, :comments_count
  end
end
