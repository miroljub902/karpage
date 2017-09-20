# frozen_string_literal: true

require 'test_helper'
require_relative '../api_controller_test'

class Api::UpvotesControllerTest < ApiControllerTest
  test 'can upvote post' do
    user = users(:john_doe)
    voteable = posts(:dummy)
    authorize_user user
    assert_difference('voteable.reload.upvotes_count', +1) do
      post :create, post_id: voteable.id, voteable_type: 'Post'
      assert_response :created
    end
  end

  test 'can remove upvote' do
    user = users(:john_doe)
    voteable = posts(:dummy)
    Upvote.vote!(voteable, user)
    authorize_user user
    assert_difference 'voteable.reload.upvotes_count', -1 do
      delete :destroy, post_id: voteable.id, voteable_type: 'Post'
      assert_response :ok
    end
  end
end
