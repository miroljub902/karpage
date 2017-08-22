# frozen_string_literal: true

class AddProfileBackgroundCropParamsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_background_crop_params, :string
  end
end
