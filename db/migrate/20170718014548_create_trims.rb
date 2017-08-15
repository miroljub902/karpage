class CreateTrims < ActiveRecord::Migration
  def change
    create_table :trims do |t|
      t.references :model, index: true, null: false
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps null: false
    end

    add_index :trims, %i[model_id slug], unique: true

    reversible do |dir|
      dir.up { execute 'CREATE UNIQUE INDEX index_trims_on_name ON trims (model_id, LOWER(name))' }
      dir.down { remove_index :trims, :name }
    end
  end
end
