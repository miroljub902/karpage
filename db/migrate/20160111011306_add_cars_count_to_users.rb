class AddCarsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cars_count, :integer, null: false, default: 0
    reversible do |dir|
      dir.up do
        execute 'UPDATE users SET cars_count = (SELECT COUNT(*) FROM cars WHERE cars.user_id = users.id)'
      end
    end
  end
end
