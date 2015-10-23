class AddSortingToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :sorting, :integer
    add_index :photos, %i(attachable_type attachable_id sorting)
  end
end
