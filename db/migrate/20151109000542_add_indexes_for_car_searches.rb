class AddIndexesForCarSearches < ActiveRecord::Migration
  def change
    add_index :cars, :description
  end
end
