class AddDeviceInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :device_info, :jsonb
  end
end
