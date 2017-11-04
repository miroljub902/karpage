class CreateHashtagUses < ActiveRecord::Migration[5.1]
  def change
    create_table :hashtag_uses do |t|
      t.references :hashtag, index: true
      t.references :taggable, polymorphic: true, index: true

      t.timestamps
    end

    add_index :hashtag_uses, :created_at
  end
end
