class AddUserTypeToUsers < ActiveRecord::Migration[5.1]
  def self.up
    add_column :users, :user_type, :string
  end
 
  def self.down
    remove_column :users, :user_type
  end
end
