# frozen_string_literal: true

class CarSinglesController < ApplicationController
  before_action :require_user

  def new
    respond_to do |format|
      format.js {
        render '_modals/new', locals: { id: 'modalNewSingle', content: 'new', options: { type: params[:type] } }
      }
      format.html {
        redirect_to profile_path(current_user), notice: 'There was an unexpected error, please try again later.'
      }
    end
  end

  def create
    return redirect_to(profile_path(current_user)) unless params[:single] && !car_limit?

    case params[:type]
    when 'dream-cars'
      current_user.dream_cars.create(single_params)
    else
      return render_404
    end

    redirect_to profile_path(current_user)
  end

  def destroy
    photo = current_user.singles.find(params[:id])
    photo.destroy
    redirect_to profile_path(current_user)
  end

  private

  def car_limit?
    case params[:type]
    when 'dream-cars'
      current_user.dream_cars.count == 3
    end
  end

  def single_params
    params.require(:single).permit(:image)
  end
end
