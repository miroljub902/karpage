class CarSinglesController < ApplicationController
  before_action :require_user

  def new
    render '_modals/new', locals: { id: 'modalNewSingle', content: 'new', options: { type: params[:type] } }
  end

  def create
    return redirect_to(user_path) unless params[:single] && current_user.dream_cars.count < 3

    case params[:type]
    when 'dream-cars'
      current_user.dream_cars.create(single_params)
    when 'next-car'
      current_user.create_next_car(single_params) unless current_user.next_car
    else
      return render_404
    end

    redirect_to user_path
  end

  def destroy
    photo = current_user.singles.find(params[:id])
    photo.destroy
    redirect_to user_path
  end

  private

  def single_params
    params.require(:single).permit(:image)
  end
end
