class IndexUsersDeviceInfo < ActiveRecord::Migration
  def change
    add_index :users, :device_info, using: :gin
  end
end
