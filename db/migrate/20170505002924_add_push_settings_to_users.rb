class AddPushSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :push_settings, :jsonb, null: false, default: {}
  end
end
