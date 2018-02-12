# frozen_string_literal: true

class Api::CommentSerializer < ApiSerializer
  include ImgixRefileHelper
  include Imgix::Rails::UrlHelper

  attributes %i[id user_id body image_url created_at]
  has_one :user, serializer: Api::UserSerializer::PublicProfile

  def image_url
    ix_refile_image_url object, :photo
  end

  def body
    ApplicationHelper.auto_link(object.body)
  end
end
