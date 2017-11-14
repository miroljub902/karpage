# frozen_string_literal: true

require 'test_helper'
require_relative '../api_controller_test'

class Api::PostsControllerTest < ApiControllerTest
  setup do
    mock_request :s3
  end

  test 'returns posts' do
    user = users(:john_doe)
    user.posts.create! body: 'Howdy', photo_id: 'dummy'
    get :index
    assert_response :ok
  end

  test 'can create post' do
    user = users(:john_doe)
    authorize_user user
    assert_difference 'user.posts.count' do
      post :create, params: { post: { body: 'Howdy', photo_id: 'dummy' } }
      assert_response :created
    end
  end

  test 'can create post on channel by name' do
    user = users(:john_doe)
    authorize_user user
    channel = PostChannel.create! name: 'monday'
    assert_difference 'user.posts.count' do
      post :create, params: { post: { body: 'Howdy', post_channel_name: 'monday', photo_id: 'dummy' } }
      assert_response :created
    end
    post = Post.find json_response['post']['id']
    assert_equal post.post_channel_id, channel.id
  end

  test 'can update post' do
    user = users(:john_doe)
    post = user.posts.create! body: 'Howdy', photo_id: 'dummy'
    authorize_user user
    patch :update, params: { id: post.id, post: { body: 'Updated' } }
    assert_response :no_content
    assert_equal 'Updated', post.reload.body
  end

  test 'returns post' do
    user = users(:john_doe)
    post = user.posts.create! body: 'Howdy', photo_id: 'dummy'
    get :show, params: { id: post.id }
    assert_response :ok
  end

  test 'can destroy post' do
    mock_request :s3
    user = users(:john_doe)
    post = user.posts.create! body: 'Howdy', photo_id: 'dummy'
    authorize_user user
    delete :destroy, params: { id: post.id }
    assert_response :no_content
    assert_raise { post.reload }
  end

  test 'returns user posts' do
    user = users(:john_doe)
    user2 = users(:friend)
    user.posts.create! body: 'Nope', photo_id: 'dummy'
    post = user2.posts.create! body: 'Howdy', photo_id: 'dummy'
    authorize_user user
    get :index, params: { user_id: user2.id }
    assert_equal 1, json_response['posts'].size
    assert_equal "<p>#{post.body}</p>", json_response['posts'].first['body']
  end

  test 'autolinks URLs' do
    user = users(:john_doe)
    user_post = user.posts.create! body: 'A link: http://google.com', photo_id: 'dummy'
    get :index, params: { user_id: user.id }
    body = json_response['posts'].find { |p| p['id'] == user_post.id }['body']
    assert_match(/a href=/, body)
  end

  test 'returns post photos' do
    user = users(:john_doe)
    user_post = user.posts.create! body: 'Howdy', photos_attributes: [{ image_id: 'dummy' }]
    get :index
    assert json_response['posts'][0].key?('photos')
    assert_equal user_post.photo_ids.first, json_response['posts'][0]['photos'][0]['id']
  end

  test 'feed returns comments' do
    user       = users(:john_doe)
    friend     = users(:friend)
    friend_post = friend.posts.create! body: 'Howdy', photos_attributes: [{ image_id: 'dummy' }]
    friend_post.comments.create! user: friend, body: 'Nice'
    user.follow! friend
    authorize_user user
    get :feed
    assert json_response['posts'][0].key?('comments')
    assert_equal 'Nice', json_response['posts'][0]['comments'][0]['body']
  end
end
