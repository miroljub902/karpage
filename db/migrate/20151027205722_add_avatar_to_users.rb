# frozen_string_literal: true

class AddAvatarToUsers < ActiveRecord::Migration
  def change
    # rubocop:disable Rails/ReversibleMigration
    change_table :users do |t|
      t.string :avatar_id
      t.string :avatar_filename
      t.integer :avatar_size
      t.string :avatar_content_type
    end
  end
end
