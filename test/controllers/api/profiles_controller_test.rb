require 'test_helper'
require_relative '../api_controller_test'

class Api::ProfilesControllerTest < ApiControllerTest
  test 'return other user info' do
    user = users(:john_doe)
    get :show, id: user.login
    assert_response :ok
    assert !json_response['user'].has_key?('email')
  end

  test 'returns cars' do
    user = users(:john_doe)
    user.dream_cars.create! image_id: 'dummy'
    user.create_next_car! image_id: 'dummy'
    user.cars << cars(:first)
    user.cars << cars(:current)
    user.cars << cars(:past)
    get :show, id: user.login
    puts response.body
    %w(next_car first_car current_cars previous_cars dream_cars).each do |key|
      assert json_response.has_key?(key), "No #{key} key"
      assert_equal 1, json_response[key].size, "#{key} != 1" if json_response[key].is_a?(Array)
      assert json_response[key].present?, "#{key} not present"
    end
  end
end
