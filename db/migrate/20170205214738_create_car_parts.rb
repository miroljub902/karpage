# frozen_string_literal: true

class CreateCarParts < ActiveRecord::Migration
  def change
    create_table :car_parts do |t|
      t.references :car, index: true, foreign_key: false
      t.string :type
      t.string :manufacturer
      t.string :model
      t.decimal :price, precision: 12, scale: 2

      t.timestamps null: false
    end
  end
end
