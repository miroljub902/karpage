class AddSortingToCars < ActiveRecord::Migration
  def change
    add_column :cars, :sorting, :integer
  end
end
