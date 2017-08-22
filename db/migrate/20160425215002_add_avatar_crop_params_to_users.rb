# frozen_string_literal: true

class AddAvatarCropParamsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :avatar_crop_params, :string
  end
end
