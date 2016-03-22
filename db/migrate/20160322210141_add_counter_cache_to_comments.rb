class AddCounterCacheToComments < ActiveRecord::Migration
  def change
    add_column :cars, :comments_count, :integer, null: false, default: 0
    add_column :posts, :comments_count, :integer, null: false, default: 0
    reversible do |dir|
      dir.up do
        execute "UPDATE cars SET comments_count = (SELECT COUNT(*) FROM comments WHERE commentable_type = 'Car' AND commentable_id = cars.id)"
        execute "UPDATE posts SET comments_count = (SELECT COUNT(*) FROM comments WHERE commentable_type = 'Post' AND commentable_id = posts.id)"
      end
    end
  end
end
