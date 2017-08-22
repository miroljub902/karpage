# frozen_string_literal: true

class AddOfficialToCarTables < ActiveRecord::Migration
  def change
    add_column :makes, :official, :boolean, null: false, default: false, index: true
    add_column :models, :official, :boolean, null: false, default: false, index: true
    add_column :trims, :official, :boolean, null: false, default: false, index: true
  end
end
