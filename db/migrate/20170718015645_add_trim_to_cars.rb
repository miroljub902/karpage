# frozen_string_literal: true

class AddTrimToCars < ActiveRecord::Migration
  def change
    add_reference :cars, :trim, index: true
  end
end
