# frozen_string_literal: true

class AddPostsCountToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :posts_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        User.update_all 'posts_count = (SELECT COUNT(*) FROM posts WHERE user_id = users.id)'
      end
    end
  end
end
