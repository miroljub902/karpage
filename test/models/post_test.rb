# frozen_string_literal: true

require 'test_helper'

class PostTest < ActiveSupport::TestCase
  setup do
    @post = posts(:dummy)
    @user = users(:john_doe)
  end

  test 'upvote changes count' do
    Upvote.toggle!(@post, @user)
    assert_equal 1, @post.reload.upvotes_count
    Upvote.toggle!(@post, @user)
    assert_equal 0, @post.reload.upvotes_count
  end
end
