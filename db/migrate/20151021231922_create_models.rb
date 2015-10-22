class CreateModels < ActiveRecord::Migration
  def change
    create_table :models do |t|
      t.references :make, index: true, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps null: false
    end

    add_index :models, %i(make_id slug), unique: true

    reversible do |dir|
      dir.up { execute 'CREATE UNIQUE INDEX index_models_on_name ON models (make_id, LOWER(name))' }
      dir.down { remove_index :models, :name }
    end
  end
end
