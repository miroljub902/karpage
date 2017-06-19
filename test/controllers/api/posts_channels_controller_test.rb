require 'test_helper'
require_relative '../api_controller_test'

class Api::PostsChannelsControllerTest < ApiControllerTest
  setup do
    Post.delete_all
    @channel = PostChannel.create!(name: 'dummy')
    @post = @channel.posts.create!(body: 'dummy', photo_id: 'dummy', user: users(:john_doe))
  end

  test 'returns channels' do
    get :index
    assert_response :ok
  end

  test 'retrieves channel posts' do
    get :show, id: @channel.name
    assert_response :ok
    assert_equal 1, json_response['posts'].size
    assert_equal @post.id, json_response['posts'].first['id']
  end
end
