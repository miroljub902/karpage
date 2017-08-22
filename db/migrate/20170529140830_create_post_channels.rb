# frozen_string_literal: true

class CreatePostChannels < ActiveRecord::Migration
  def change
    create_table :post_channels do |t|
      t.string :name
    end
    add_index :post_channels, :name, unique: true
    add_reference :posts, :post_channel, index: true
  end
end
