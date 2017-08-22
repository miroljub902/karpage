# frozen_string_literal: true

class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.references :user, index: true
      t.references :reportable, polymorphic: true, index: true
      t.string :reason, null: false
      t.json :extra_data

      t.timestamps null: false
    end
    add_index :reports, :reason
  end
end
