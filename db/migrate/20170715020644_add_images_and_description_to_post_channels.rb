# frozen_string_literal: true

class AddImagesAndDescriptionToPostChannels < ActiveRecord::Migration
  # rubocop:disable Rails/ReversibleMigration
  def change
    change_table :post_channels do |t|
      t.string :description
      t.string :image_id
      t.string :image_filename
      t.integer :image_size
      t.string :image_content_type
      t.string :thumb_id
      t.string :thumb_filename
      t.integer :thumb_size
      t.string :thumb_content_type
    end
  end
end
