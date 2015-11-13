class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.belongs_to :user
      t.belongs_to :followee

      t.timestamps null: false
    end
    add_index :follows, %i(user_id followee_id), unique: true
  end
end
