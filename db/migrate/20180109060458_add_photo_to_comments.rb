# frozen_string_literal: true

class AddPhotoToComments < ActiveRecord::Migration[5.1]
  def change
    change_table :comments do |t|
      t.string :photo_id
      t.string :photo_filename
      t.integer :photo_size
      t.string :photo_content_type
    end
  end
end
