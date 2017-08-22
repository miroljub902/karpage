# frozen_string_literal: true

class AddTypeToCars < ActiveRecord::Migration
  def change
    add_column :cars, :type, :string
    add_index :cars, :type
  end
end
