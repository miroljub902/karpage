# frozen_string_literal: true

require 'test_helper'
require_relative '../api_controller_test'

class Api::BusinessesControllerTest < ApiControllerTest
  test 'user can create business profile' do
    user = users(:john_doe)
    assert_difference 'Business.count', +1 do
      authorize_user user
      post :create, params: { business: businesses(:full).attributes }
      assert_response :created
    end
    skip_check = %w[id user_id created_at updated_at]
    original = businesses(:full).attributes.except(*skip_check)
    assert_equal original, user.business.attributes.except(*skip_check)
  end

  test 'user cannot create business profile if one already exists' do
    user = users(:john_doe)
    user.business = businesses(:full)
    assert_no_difference 'Business.count' do
      authorize_user user
      post :create, params: { business: businesses(:full).attributes }
      assert_response :forbidden
    end
  end

  test 'unauthenticated user cannot create business profile' do
    user = users(:john_doe)
    user.business = businesses(:full)
    assert_no_difference 'Business.count' do
      post :create, params: { business: businesses(:full).attributes }
      assert_response :unauthorized
    end
  end

  test 'any user can retrieve business profile' do
    user = users(:john_doe)
    user.business = businesses(:full)
    get :show, params: { id: user.business.id }
    assert_response :ok
  end

  test 'user can update business profile' do
    user = users(:john_doe)
    user.business = businesses(:full)
    authorize_user user
    patch :update, params: { id: user.business.id, business: { name: 'Updated Name' } }
    assert_response :no_content
    assert_equal 'Updated Name', user.business.reload.name
  end

  test 'user can remove business profile' do
    user = users(:john_doe)
    user.business = businesses(:full)
    authorize_user user
    assert_difference 'Business.count', -1 do
      delete :destroy, params: { id: user.business.id }
      assert_response :no_content
    end
    assert user.reload.business.nil?
  end
end
