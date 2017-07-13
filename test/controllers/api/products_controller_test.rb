require 'test_helper'
require_relative '../api_controller_test'

class Api::ProductsControllerTest < ApiControllerTest
  setup do
    @business = businesses(:full)
    @business.update_attribute :user_id, users(:john_doe).id
  end

  test 'get business products' do
    product = products(:one)
    @business.products = [product]
    get :index, business_id: @business.id
    assert_response :ok
    assert_equal 1, json_response.size
    assert_equal product.title, json_response['products'].first['title']
  end

  test 'get product details' do
    product = products(:one)
    @business.products = [product]
    get :show, business_id: @business.id, id: product.id
    assert_response :ok
    assert_equal product.id, json_response['product']['id']
  end

  test 'business user can create product' do
    authorize_user @business.user
    assert_difference '@business.products.count', +1 do
      post :create, business_id: @business.id, product: products(:one).attributes
      assert_response :created
    end
    skip_check = %w(id business_id created_at updated_at)
    original = products(:one).attributes.except(*skip_check)
    assert_equal original, @business.products.last.attributes.except(*skip_check)
  end

  test 'non-business user cannot create product' do
    authorize_user users(:friend)
    post :create, business_id: @business.id, product: products(:one).attributes
    assert_response :not_found
  end

  test 'user can update product' do
    product = products(:one)
    product.update_attribute :business_id, @business.id
    authorize_user @business.user
    patch :update, business_id: @business.id, id: product.id, product: { title: 'New Title' }
    assert_response :no_content
    assert_equal 'New Title', product.reload.title
  end

  test 'non-owner cannot update product' do
    authorize_user @business.user
    product = products(:one)
    patch :update, business_id: @business.id, id: product.id, product: { title: 'New Title' }
    assert_response :forbidden
    assert_not_equal 'New Title', product.reload.title
  end

  test 'owner can delete product' do
    product = products(:one)
    product.update_attribute :business_id, @business.id
    authorize_user @business.user
    assert_difference '@business.products.count + Product.count', -2 do
      delete :destroy, business_id: @business.id, id: product.id
      assert_response :no_content
    end
  end

  test 'non-owner cannot delete product' do
    product = products(:one)
    authorize_user @business.user
    assert_no_difference '@business.products.count + Product.count' do
      delete :destroy, business_id: @business.id, id: product.id
      assert_response :forbidden
    end
  end
end
