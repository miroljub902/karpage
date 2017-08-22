# frozen_string_literal: true

require 'test_helper'

class ProfileUploaderTest < ActiveSupport::TestCase
  setup do
    @uploader = ProfileUploader.new(OpenStruct.new)
  end

  test 'handle_network_errors returns default on error' do
    result = @uploader.handle_network_errors max_retries: 0, default: -> { 'howdy!' } do
      raise Net::ReadTimeout, 'dummy'
    end
    assert_equal 'howdy!', result
  end

  test 'handle_network_errors returns default on nil' do
    result = @uploader.handle_network_errors max_retries: 0, default: -> { 'howdy!' } do
      nil
    end
    assert_equal 'howdy!', result
  end

  test 'handle_network_errors returns yielded' do
    result = @uploader.handle_network_errors max_retries: 0, default: -> { 'howdy!' } do
      'hello'
    end
    assert_equal 'hello', result
  end
end
