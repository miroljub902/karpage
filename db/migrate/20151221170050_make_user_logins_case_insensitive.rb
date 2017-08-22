# frozen_string_literal: true

class MakeUserLoginsCaseInsensitive < ActiveRecord::Migration
  def change
    enable_extension 'citext'
    change_column :users, :login, :citext
  end
end
