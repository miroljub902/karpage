class AddExtraFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :description, :string
    add_column :users, :twitter_uid, :string
    add_column :users, :location, :string
  end
end
