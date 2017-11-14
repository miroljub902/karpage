# frozen_string_literal: true

class Api::HashtagsController < ApiController
  def index
    hashtags = Hashtag.most_used.simple_search(params[:search]).limit(100)
    respond_with hashtags
  end
end
