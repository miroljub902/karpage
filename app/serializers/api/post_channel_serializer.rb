# frozen_string_literal: true

class Api::PostChannelSerializer < ApiSerializer
  include ImgixRefileHelper
  include Imgix::Rails::UrlHelper

  attributes %i[id name description image_url thumb_url]

  def image_url
    ix_refile_image_url object, :image
  end

  def thumb_url
    ix_refile_image_url object, :thumb
  end
end
