class AddProfileThumbnailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_thumbnail_id, :string
  end
end
