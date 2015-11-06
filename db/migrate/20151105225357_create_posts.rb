class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :user, index: true, foreign_key: true
      t.text :body, null: false
      t.integer :views, null: false, default: 0

      t.string :photo_id
      t.string :photo_filename
      t.integer :photo_size
      t.string :photo_content_type

      t.timestamps null: false
    end
  end
end
