# frozen_string_literal: true

class Api::ProductsController < ApiController
  before_action :require_user, except: %i[index show]
  before_action :find_business, only: %i[index show]
  before_action :find_own_business, only: %i[create update destroy]

  def_param_group :product do
    param :product, Hash, required: true, desc: 'Root for product attributes if passing JSON' do
      param :title, String, required: true
      param :subtitle, String
      param :price, :number
      param :link, String
      param :description, String
      param :category, String

      param :photos_attributes, Array do
        param :id, :number, desc: 'Required only when updating a photo'
        param :_destroy, String, desc: 'Set to "1" to destroy the photo'
        param :image_id, String, required: true
        param :image_content_type, String, required: true
        param :image_size, Integer, required: true
        param :image_filename, String, required: true
        param :sorting, Integer
      end
    end
  end

  api!
  def index
    @products = @business.products
    respond_with :api, @business, @products
  end

  api!
  def show
    @product = @business.products.find(params[:id])
    respond_with :api, @business, @product, status: :ok
  end

  api!
  param_group :product
  def create
    @product = @business.products.create(product_params)
    respond_with :api, @business, @product, status: :created
  end

  api!
  param_group :product
  def update
    @product = Product.find_by(id: params[:id], business_id: @business.id)
    return(render nothing: true, status: :forbidden) if @product.nil?
    @product.update_attributes(product_params)
    respond_with :api, @business, @product
  end

  api!
  def destroy
    @product = Product.find_by(id: params[:id], business_id: @business.id)
    return(render nothing: true, status: :forbidden) if @product.nil?
    @product.destroy
    respond_with :api, @business, @product
  end

  private

  def product_params
    params.require(:product).permit(
      %i[title subtitle price link description category],
      photos_attributes: %i[id _destroy image_id image_content_type image_size image_filename sorting]
    )
  end

  def find_business
    @business = Business.find(params[:business_id])
  end

  def find_own_business
    @business = Business.find_by!(id: params[:business_id], user_id: current_user.id)
  end
end
