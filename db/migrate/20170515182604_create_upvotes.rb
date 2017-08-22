# frozen_string_literal: true

class CreateUpvotes < ActiveRecord::Migration
  def change
    create_table :upvotes do |t|
      t.references :voteable, index: true, polymorphic: true
      t.references :user, index: true

      t.timestamps null: false
    end

    add_index :upvotes, %i[voteable_id voteable_type user_id], unique: true
  end
end
