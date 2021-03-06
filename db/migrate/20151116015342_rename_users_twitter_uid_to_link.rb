# frozen_string_literal: true

class RenameUsersTwitterUidToLink < ActiveRecord::Migration
  def change
    rename_column :users, :twitter_uid, :link
  end
end
