# frozen_string_literal: true

class AddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean, null: false, default: false
    add_index :users, :admin
  end
end
