# frozen_string_literal: true

class Api::BusinessesController < ApiController
  before_action :require_user, except: :show

  def show
    @business = Business.find(params[:id])
    respond_with :api, @business, status: :ok
  end

  def create
    return(render nothing: true, status: :forbidden) if current_user.business
    @business = current_user.create_business(business_params)
    respond_with :api, @business, status: :created
  end

  def update
    @business = Business.find_by(id: params[:id], user_id: current_user.id)
    return(render nothing: true, status: :forbidden) if @business.nil?
    @business.update_attributes(business_params)
    respond_with :api, @business
  end

  def destroy
    @business = Business.find_by(id: params[:id], user_id: current_user.id)
    return(render nothing: true, status: :forbidden) if @business.nil?
    @business.destroy
    respond_with :api, @business
  end

  private

  def business_params
    params.require(:business).permit(
      %i[name address city state post_code description phone email url instagram_id keywords]
    )
  end
end
