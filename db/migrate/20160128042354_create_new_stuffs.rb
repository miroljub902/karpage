class CreateNewStuffs < ActiveRecord::Migration
  def change
    create_table :new_stuffs do |t|
      t.references :user, index: true
      t.references :stuff_owner, index: true
      t.string :stuff
      t.datetime :last_at

      t.timestamps null: false
    end
    add_index :new_stuffs, :stuff
    add_index :new_stuffs, :last_at
  end
end
