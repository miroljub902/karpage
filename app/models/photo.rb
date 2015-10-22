class Photo < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  attachment :image
end
