class CreateCars < ActiveRecord::Migration
  def change
    create_table :cars do |t|
      t.references :model, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :year, null: false
      t.string :slug, null: false
      t.text :description
      t.boolean :first, null: false, default: false
      t.boolean :current, null: false, default: true
      t.boolean :past, null: false, default: false

      t.timestamps null: false
    end

    add_index :cars, :year
    add_index :cars, %i(user_id slug), unique: true
    add_index :cars, :first
    add_index :cars, :current
    add_index :cars, :past
  end
end
