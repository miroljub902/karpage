class AddFeaturedOrderToCarsAndUsers < ActiveRecord::Migration
  def change
    add_column :cars, :featured_order, :integer
    add_column :users, :featured_order, :integer
    add_index :cars, :featured_order
    add_index :users, :featured_order
  end
end
