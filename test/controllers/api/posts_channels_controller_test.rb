# frozen_string_literal: true

require 'test_helper'
require_relative '../api_controller_test'

class Api::PostsChannelsControllerTest < ApiControllerTest
  setup do
    mock_request :s3
    Post.delete_all
    @channel = PostChannel.create!(name: 'dummy')
    @user = users(:john_doe)
    @post = @channel.posts.create!(body: 'dummy', photo_id: 'dummy', user: @user)
  end

  test 'returns channels' do
    get :index
    assert_response :ok
  end

  test 'retrieves channel posts' do
    get :show, params: { id: @channel.name }
    assert_response :ok
    assert_equal 1, json_response['posts'].size
    assert_equal @post.id, json_response['posts'].first['id']
  end

  test 'retrieve posts in newest order' do
    Upvote.vote! @post, @user
    @channel.posts.create!(body: 'newest', photo_id: 'dummy', user: @user)
    get :show, params: { id: @channel.name, sort: 'newest' }
    assert_equal %w[newest dummy], json_response['posts'].map { |p| p['plain_body'] }
  end
end
