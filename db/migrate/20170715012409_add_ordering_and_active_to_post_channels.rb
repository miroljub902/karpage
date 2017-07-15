class AddOrderingAndActiveToPostChannels < ActiveRecord::Migration
  def change
    add_column :post_channels, :ordering, :integer, index: true, null: false, default: 0
    add_column :post_channels, :active, :boolean, index: true, null: false, default: true
  end
end
