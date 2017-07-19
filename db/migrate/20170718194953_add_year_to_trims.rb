class AddYearToTrims < ActiveRecord::Migration
  def change
    add_column :trims, :year, :integer, index: true
    reversible do |dir|
      dir.up do
        remove_index :trims, :name
        execute 'CREATE UNIQUE INDEX index_trims_on_name ON trims (model_id, year, LOWER(name))'
      end
      dir.down do
        remove_index :trims, :name
        execute 'CREATE UNIQUE INDEX index_trims_on_name ON trims (model_id, LOWER(name))'
      end
    end
  end
end
