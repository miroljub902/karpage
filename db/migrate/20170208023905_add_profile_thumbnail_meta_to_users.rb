# frozen_string_literal: true

class AddProfileThumbnailMetaToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_thumbnail_filename, :string
    add_column :users, :profile_thumbnail_size, :integer
    add_column :users, :profile_thumbnail_content_type, :string
  end
end
