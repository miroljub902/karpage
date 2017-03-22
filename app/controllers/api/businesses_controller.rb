class Api::BusinessesController < ApiController
  before_action :require_user, except: :show

  def_param_group :business do
    param :business, Hash, required: true, desc: 'Root for business attributes if passing JSON' do
      param :name, String, required: true
      param :address, String
      param :city, String
      param :state, String
      param :post_code, String
      param :description, String
      param :phone, String
      param :email, String
      param :url, String
      param :instagram_id, String
      param :keywords, String
    end
  end

  api!
  def show
    @business = Business.find(params[:id])
    respond_with :api, @business, status: :ok
  end

  api!
  param_group :business
  def create
    return(render nothing: true, status: :forbidden) if current_user.business
    @business = current_user.create_business(business_params)
    respond_with :api, @business, status: :created
  end

  api!
  param_group :business
  def update
    @business = Business.find_by(id: params[:id], user_id: current_user.id)
    return(render nothing: true, status: :forbidden) if @business.nil?
    @business.update_attributes(business_params)
    respond_with :api, @business
  end

  api!
  def destroy
    @business = Business.find_by(id: params[:id], user_id: current_user.id)
    return(render nothing: true, status: :forbidden) if @business.nil?
    @business.destroy
    respond_with :api, @business
  end

  private

  def business_params
    params.require(:business).permit(%i(name address city state post_code description phone email url instagram_id keywords))
  end
end
