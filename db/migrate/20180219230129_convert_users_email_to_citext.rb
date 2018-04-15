class ConvertUsersEmailToCitext < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        change_column :users, :email, :citext
      end

      dir.down do
        change_column :users, :email, :string
      end
    end
  end
end
