# frozen_string_literal: true

class CreateHashtags < ActiveRecord::Migration[5.1]
  def change
    create_table :hashtags do |t|
      t.citext :tag
      t.integer :hashtag_uses_count, null: false, default: 0

      t.timestamps
    end
    add_index :hashtags, :tag, unique: true
    add_index :hashtags, :hashtag_uses_count
  end
end
