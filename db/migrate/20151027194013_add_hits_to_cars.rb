class AddHitsToCars < ActiveRecord::Migration
  def change
    add_column :cars, :hits, :integer, null: false, default: 0
    add_index :cars, :hits
  end
end
