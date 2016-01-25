class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.references :likeable, index: true, polymorphic: true
      t.references :user, index: true

      t.timestamps null: false
    end
    add_index :likes, %i(likeable_type likeable_id user_id), unique: true
  end
end
