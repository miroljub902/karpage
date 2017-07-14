class NormalizeCarTypes < ActiveRecord::Migration
  def up
    execute "UPDATE cars SET type = 'first_car' WHERE first = 't'"
    execute "UPDATE cars SET type = 'current_car' WHERE current = 't'"
    execute "UPDATE cars SET type = 'past_car' WHERE past = 't'"
    remove_column :cars, :first
    remove_column :cars, :current
    remove_column :cars, :past
  end

  def down
    add_column :cars, :first, :boolean, null: false, default: false, index: true
    add_column :cars, :current, :boolean, null: false, default: true, index: true
    add_column :cars, :past, :boolean, null: false, default: false, index: true
    execute "UPDATE cars SET first = 't' WHERE type = 'first_car'"
    execute "UPDATE cars SET current = 't' WHERE type = 'current_car'"
    execute "UPDATE cars SET past = 't' WHERE type = 'past_car'"
  end
end
