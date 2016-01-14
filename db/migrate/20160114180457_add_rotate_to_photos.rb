class AddRotateToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :rotate, :integer
  end
end
