# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.references :business, index: true
      t.string :title
      t.string :subtitle
      t.decimal :price, precision: 8, scale: 2
      t.string :link
      t.string :description
      t.string :category

      t.timestamps null: false
    end
    add_index :products, :category
  end
end
