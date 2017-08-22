# frozen_string_literal: true

require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  setup :set_json_header

  def json_response
    JSON.parse response.body
  end

  def set_json_header
    @request.headers['Accept'] = 'application/json'
  end

  def authorize_user(user)
    @request.headers['Authorization'] = user.access_token
  end
end
