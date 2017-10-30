# frozen_string_literal: true

class AddFbOgRefreshedToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :fb_og_refreshed, :boolean, null: false, default: true
    add_column :users, :fb_og_refreshed_at, :datetime
    change_column_default :users, :fb_og_refreshed, from: true, to: false
    add_index :users, :fb_og_refreshed
  end
end
