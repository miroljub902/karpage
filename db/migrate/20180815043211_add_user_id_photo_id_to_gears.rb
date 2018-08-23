class AddUserIdPhotoIdToGears < ActiveRecord::Migration[5.1]
  def self.up
    # add_reference :gears, :users, index:true
    # add_foreign_key :gears, :users
    # add_reference :gears, :photos, index:true
    # add_foreign_key :gears, :photos
    add_reference :gears, :user, foreign_key: true
    add_reference :gears, :photo, foreign_key: true
  end

  def self.down
  end
end
