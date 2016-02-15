require 'test_helper'
require_relative '../api_controller_test'

class Api::PostsControllerTest < ApiControllerTest
  test 'returns posts' do
    user = users(:john_doe)
    user.posts.create! body: 'Howdy'
    get :index
    assert_response :ok
  end

  test 'can create post' do
    user = users(:john_doe)
    authorize_user user
    assert_difference 'user.posts.count' do
      post :create, post: { body: 'Howdy' }
      assert_response :created
    end
  end

  test 'can update post' do
    user = users(:john_doe)
    post = user.posts.create! body: 'Howdy'
    authorize_user user
    patch :update, id: post.id, post: { body: 'Updated' }
    assert_response :no_content
    assert_equal 'Updated', post.reload.body
  end

  test 'returns post' do
    user = users(:john_doe)
    post = user.posts.create! body: 'Howdy'
    authorize_user user
    get :show, id: post.id
    assert_response :ok
  end

  test 'can destroy post' do
    user = users(:john_doe)
    post = user.posts.create! body: 'Howdy'
    authorize_user user
    delete :destroy, id: post.id
    assert_response :no_content
    assert_raise { post.reload }
  end
end
