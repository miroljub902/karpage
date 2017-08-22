# frozen_string_literal: true

class CreateBusinesses < ActiveRecord::Migration
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :businesses do |t|
      t.references :user, index: true
      t.string :name
      t.string :address
      t.string :state
      t.string :city
      t.string :post_code
      t.string :phone
      t.string :email
      t.string :url
      t.string :instagram_id
      t.string :description
      t.string :keywords

      t.timestamps null: false
    end
    add_index :businesses, :keywords
  end
end
