# frozen_string_literal: true

class Api::GearsController < ApiController
  before_action :require_user, only: %i[create]

  # rubocop:disable Metrics/AbcSize
  def index
    @gears = Gear.all
    respond_with @gears
  end

  def show
    @gear = Gear.find_by(id: params[:id])
    return render_404 unless @gear
    respond_with @gear
  end

  def create
    # current_user = User.find(1);
    gear = current_user.gears.create(gear_params)
    # respond_with :api, @gear, status: :created, include: []
    respond_with :api, gear  
  end

  # def update
  #   @gear = current_user.gears.includes(:sorted_photos, :user).find(params[:id])
  #   @gear.update_attributes gear_params
  #   respond_with @gear, include: []
  # end

  # def destroy
  #   @gear = current_user.gears.includes(:sorted_photos, :user).find(params[:id])
  #   @gear.destroy
  #   respond_with @gear, include: []
  # end

  private

  def gear_params
    params.require(:gear).permit(
      :name, :photo_id
    )
  end
end
