# frozen_string_literal: true

class Block < ActiveRecord::Base
  belongs_to :user
  belongs_to :blocked_user, class_name: 'User'
end
