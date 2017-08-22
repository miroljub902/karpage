# frozen_string_literal: true

class AddProfileBackgroundToUsers < ActiveRecord::Migration
  # rubocop:disable Rails/ReversibleMigration
  def change
    change_table :users do |t|
      t.string :profile_background_id
      t.string :profile_background_filename
      t.integer :profile_background_size
      t.string :profile_background_content_type
    end
  end
end
