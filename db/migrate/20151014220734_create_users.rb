# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :login
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token
      t.string :single_access_token
      t.string :perishable_token

      t.integer   :login_count,        null: false, default: 0
      t.integer   :failed_login_count, null: false, default: 0
      t.datetime  :last_request_at
      t.datetime  :current_login_at
      t.datetime  :last_login_at
      t.string    :current_login_ip
      t.string    :last_login_ip

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :login, unique: true
    add_index :users, :persistence_token
    add_index :users, :single_access_token
    add_index :users, :perishable_token
  end
end
