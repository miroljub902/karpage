require 'test_helper'
require_relative '../api_controller_test'

class Api::UpvotesControllerTest < ApiControllerTest
  test 'can upvote post' do
    user = users(:john_doe)
    post = posts(:dummy)
    authorize_user user
    assert_difference 'post.reload.upvotes_count', +1 do
      self.post :create, post_id: post.id, voteable_type: 'Post'
      assert_response :created
    end
  end

  test 'can remove upvote' do
    user = users(:john_doe)
    post = posts(:dummy)
    Upvote.vote!(post, user)
    authorize_user user
    assert_difference 'post.reload.upvotes_count', -1 do
      delete :destroy, post_id: post.id, voteable_type: 'Post'
      assert_response :ok
    end
  end
end
