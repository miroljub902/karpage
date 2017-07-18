class AddCoordsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :point, :geography
    add_column :users, :lat, :decimal, precision: 9, scale: 5
    add_column :users, :lng, :decimal, precision: 9, scale: 5

    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE TRIGGER trigger_users_on_lat_lng
          BEFORE INSERT OR UPDATE OF lat, lng ON users
          FOR EACH ROW
          EXECUTE PROCEDURE set_point_from_lat_lng()
        SQL
      end

      dir.down do
        execute 'DROP TRIGGER trigger_users_on_lat_lng ON users'
      end
    end
  end
end
