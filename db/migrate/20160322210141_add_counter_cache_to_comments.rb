# frozen_string_literal: true

class AddCounterCacheToComments < ActiveRecord::Migration
  # rubocop:disable Metrics/MethodLength
  def change
    add_column :cars, :comments_count, :integer, null: false, default: 0
    add_column :posts, :comments_count, :integer, null: false, default: 0
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE cars SET comments_count = (
            SELECT COUNT(*) FROM comments WHERE commentable_type = 'Car' AND commentable_id = cars.id
          )
        SQL
        execute <<-SQL
          UPDATE posts SET comments_count = (
            SELECT COUNT(*) FROM comments WHERE commentable_type = 'Post' AND commentable_id = posts.id
          )
        SQL
      end
    end
  end
end
