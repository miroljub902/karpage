# frozen_string_literal: true

class RemoveSlugFromTrims < ActiveRecord::Migration
  def change
    remove_column :trims, :slug, :string, null: false
  end
end
