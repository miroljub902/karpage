# frozen_string_literal: true

class CreateMakes < ActiveRecord::Migration
  def change
    create_table :makes do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps null: false
    end

    add_index :makes, :slug, unique: true

    reversible do |dir|
      dir.up { execute 'CREATE UNIQUE INDEX index_makes_on_name ON makes (LOWER(name))' }
      dir.down { remove_index :makes, :name }
    end
  end
end
