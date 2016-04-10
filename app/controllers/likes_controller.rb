class LikesController < ApplicationController
  before_action :require_user

  def toggle
    redirect_back_or_default root_path unless request.xhr?
    @likeable = find_likeable
    @likeable.toggle_like!(current_user) if @likeable
  end

  private

  FINDERS = {
    Car => -> (params) {
      user = User.find_by!(login: params[:profile_id])
      user.cars.find_by!(slug: params[:car_id])
    },
    Post => -> (params) {
      user = User.find_by!(login: params[:profile_id])
      user.posts.find params[:post_id]
    }
  }

  def find_likeable
    finder = FINDERS[params[:likeable_class]]
    return render_404 unless finder
    finder.call params
  end
end
