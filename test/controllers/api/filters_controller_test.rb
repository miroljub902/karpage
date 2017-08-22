# frozen_string_literal: true

require 'test_helper'
require_relative '../api_controller_test'

class Api::FiltersControllerTest < ApiControllerTest
  test 'returns filters' do
    Filter.create! name: 'BMW', words: 'bmw'
    get :index
    assert_response :ok
    assert_equal 'BMW', json_response['filters'].first['name']
  end
end
