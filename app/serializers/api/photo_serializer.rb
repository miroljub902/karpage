# frozen_string_literal: true

class Api::PhotoSerializer < ApiSerializer
  include ImgixRefileHelper
  include Imgix::Rails::UrlHelper

  attributes %i[id created_at image_url sorting]

  def image_url
    ix_refile_image_url object, :image
  end
end
