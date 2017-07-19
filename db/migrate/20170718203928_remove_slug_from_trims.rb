class RemoveSlugFromTrims < ActiveRecord::Migration
  def change
    remove_column :trims, :slug
  end
end
