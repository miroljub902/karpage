class AddLinkToCarParts < ActiveRecord::Migration[5.1]
  def change
    add_column :car_parts, :link, :string
  end
end
