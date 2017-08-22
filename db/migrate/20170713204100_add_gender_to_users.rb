# frozen_string_literal: true

class AddGenderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gender, :string
  end
end
