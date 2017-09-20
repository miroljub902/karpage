# frozen_string_literal: true

class Api::ProductsController < ApiController
  before_action :require_user, except: %i[index show]
  before_action :find_business, only: %i[index show]
  before_action :find_own_business, only: %i[create update destroy]

  def index
    @products = @business.products
    respond_with :api, @business, @products
  end

  def show
    @product = @business.products.find(params[:id])
    respond_with :api, @business, @product, status: :ok
  end

  def create
    @product = @business.products.create(product_params)
    respond_with :api, @business, @product, status: :created
  end

  def update
    @product = Product.find_by(id: params[:id], business_id: @business.id)
    return(head :forbidden) if @product.nil?
    @product.update_attributes(product_params)
    respond_with :api, @business, @product
  end

  def destroy
    @product = Product.find_by(id: params[:id], business_id: @business.id)
    return(head :forbidden) if @product.nil?
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
