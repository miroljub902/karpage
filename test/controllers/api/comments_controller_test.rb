# frozen_string_literal: true

require 'test_helper'
require_relative '../api_controller_test'

class Api::CommentsControllerTest < ApiControllerTest
  setup do
    mock_request :s3
    ProfileThumbnailJob.stubs(:perform_later)
  end

  test 'list car comments' do
    user = users(:john_doe)
    friend = users(:friend)
    car = cars(:current)
    user.cars << car
    car.comments.create! user: friend, body: 'A comment'
    get :index, params: { car_id: car.id, commentable_type: 'Car' }
    assert_response :ok
    assert_equal 'A comment', json_response['comments'].first['body']
  end

  test 'list post comments' do
    user = users(:john_doe)
    friend = users(:friend)
    post = user.posts.create! body: 'A post', photo_id: 'dummy'
    post.comments.create! user: friend, body: 'A comment'
    get :index, params: { post_id: post.id, commentable_type: 'Post' }
    assert_response :ok
    assert_equal 'A comment', json_response['comments'].first['body']
  end

  test 'can create comment' do
    user = users(:john_doe)
    friend = users(:friend)
    user_post = user.posts.create! body: 'A post', photo_id: 'dummy'
    assert_difference 'user_post.comments.count' do
      authorize_user friend
      post :create, params: { post_id: user_post.id, commentable_type: 'Post', comment: { body: 'Howdy' } }
      assert_response :created
    end
    assert_equal 1, friend.reload.comments.count
  end

  test 'can update comment' do
    user = users(:john_doe)
    friend = users(:friend)
    post = user.posts.create! body: 'A post', photo_id: 'dummy'
    comment = post.comments.create! user: friend, body: 'A comment'
    authorize_user friend
    patch :update, params: { post_id: post.id, commentable_type: 'Post', id: comment.id, comment: { body: 'Changed' } }
    assert_response :ok
    assert_equal 'Changed', comment.reload.body
  end

  test 'can delete comment' do
    user = users(:john_doe)
    friend = users(:friend)
    post = user.posts.create! body: 'A post', photo_id: 'dummy'
    comment = post.comments.create! user: friend, body: 'A comment'
    authorize_user friend
    delete :destroy, params: { post_id: post.id, commentable_type: 'Post', id: comment.id }
    assert_response :ok
    assert_raise { comment.reload }
  end

  test 'does not return comments from blocked users' do
    user = users(:john_doe)
    fiend = users(:friend)
    post = user.posts.create! body: 'A post', photo_id: 'dummy'
    comment = post.comments.create! user: fiend, body: 'A comment'
    user.blocks.create! blocked_user: fiend
    authorize_user user
    get :index, params: { post_id: post.id, commentable_type: 'Post' }
    assert !json_response['comments'].detect { |c| c['id'] == comment.id }
  end
end
