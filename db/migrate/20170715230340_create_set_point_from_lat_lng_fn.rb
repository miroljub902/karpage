class CreateSetPointFromLatLngFn < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION set_point_from_lat_lng() RETURNS trigger AS $func$
      BEGIN
        NEW.point := ST_SetSRID(ST_Point(NEW.lng, NEW.lat), 4326);
        RETURN NEW;
      END;
      $func$ LANGUAGE plpgsql
    SQL
  end

  def down
    execute 'DROP FUNCTION set_point_from_lat_lng()'
  end
end
