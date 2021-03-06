# frozen_string_literal: true

class AddTypeToFilters < ActiveRecord::Migration
  def change
    add_column :filters, :type, :string, null: false, default: 'Filter'
  end
end
