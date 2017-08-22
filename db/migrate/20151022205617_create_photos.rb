# frozen_string_literal: true

class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :attachable_type
      t.integer :attachable_id
      t.string :photo_type
      t.string :image_id
      t.string :image_filename
      t.integer :image_size
      t.string :image_content_type

      t.timestamps null: false
    end

    add_index :photos, :photo_type
    add_index :photos, %i[attachable_type attachable_id]
  end
end
