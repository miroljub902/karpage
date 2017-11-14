# frozen_string_literal: true

class HashtagsController < ApplicationController
  layout 'simple'

  def index
    if params[:id]
      show
      render :show
    elsif request.xhr?
      @hashtags = Hashtag.unique_count.search(tag_cont: params[:search]).result
      render json: @hashtags
    end
  end

  def show
    @hashtag = Hashtag
               .select('DISTINCT ON (hashtag_uses.relatable_id, hashtag_uses.relatable_type) hashtags.*')
               .joins(:uses)
               .includes(uses: %i[relatable])
               .find_by(tag: params[:id])
    @hashtag ||= Hashtag.new(tag: params[:id])
    @hashtag = @hashtag.decorate
  end
end
