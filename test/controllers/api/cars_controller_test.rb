# frozen_string_literal: true

require 'test_helper'
require_relative '../api_controller_test'

# rubocop:disable Metrics/ClassLength
class Api::CarsControllerTest < ApiControllerTest
  setup do
    mock_request 's3'
  end

  test 'returns cars' do
    user = users(:john_doe)
    user.cars << cars(:current)
    car = user.cars.first
    car.photos.create! image_id: 'dummy'
    car.comments.create! user: users(:friend), body: 'Nice car'
    get :index
    assert_response :ok
  end

  test 'search cars' do
    user = users(:john_doe)
    user.cars << cars(:current)
    car = user.cars.first
    car.photos.create! image_id: 'dummy'
    car.comments.create! user: users(:friend), body: 'Nice car'
    get :index, params: { search: 'audi' }
    assert_response :ok
  end

  test 'filters cars' do
    filter = Filter.create! name: 'BMW', words: 'bmw'
    user = users(:john_doe)
    car1 = cars(:current)
    car2 = cars(:first)
    car1.update_column :slug, 'bmw-i7'
    car1.photos.create! image_id: 'dummy'
    car2.photos.create! image_id: 'dummy2'
    user.cars << car1
    user.cars << car2
    get :index, params: { filter_id: filter.id }
    assert_response :ok
    assert_equal 1, json_response['cars'].size
    assert_equal car1.id, json_response['cars'].first['id']
  end

  test 'can create car' do
    user = users(:john_doe)
    authorize_user user
    assert_difference 'user.cars.count' do
      post :create, params: { car: { year: '2015', make_name: 'Audi', car_model_name: 'R8' } }
      assert_response :created
    end
  end

  test 'can update car' do
    user = users(:john_doe)
    user.cars << cars(:current)
    car = user.cars.first
    authorize_user user
    patch :update, params: { id: car.id, car: { description: 'Updated' } }
    assert_response :no_content
    assert_equal 'Updated', car.reload.description
  end

  test 'returns car' do
    user = users(:john_doe)
    user.cars << cars(:current)
    car = user.cars.first
    authorize_user user
    get :show, params: { id: car.id }
    assert_response :ok
  end

  test 'returns whats new' do
    user = users(:john_doe)
    friend = users(:friend)
    car = cars(:current)
    user.cars << car
    NewStuff.reset_count(car.likes, user, owner: user, delay: true)
    NewStuff.reset_count(car.comments, user, owner: user, delay: true)
    Like.like! car, friend
    car.comments.create! user: friend, body: 'Howdy'
    authorize_user user
    get :show, params: { id: car.id }
    assert_equal 1, json_response['car']['new_likes']
    assert_equal 1, json_response['car']['new_comments']
  end

  test 'can destroy car' do
    user = users(:john_doe)
    user.cars << cars(:current)
    car = user.cars.first
    authorize_user user
    delete :destroy, params: { id: car.id }
    assert_response :no_content
    assert_raise { car.reload }
  end

  test 'can destroy car photo' do
    user = users(:john_doe)
    user.cars << cars(:current)
    car = user.cars.first
    car.photos << Photo.create(photos(:one).attributes.except('id'))
    car.photos << Photo.create(photos(:one).attributes.except('id'))
    photo = car.photos.first
    authorize_user user
    stub_request :delete, /s3/
    patch :update, params: { id: car.id, car: { photos_attributes: { id: photo.id, _destroy: true } } }
    assert_response :no_content
    assert_equal 1, car.reload.photos.count
    assert_not_equal photo.id, car.photos.first.id
  end

  test 'can add with parts list' do
    mock_request 's3'
    user = users(:john_doe)
    authorize_user user
    post :create, params: { car: {
      year: '2015', make_name: 'Audi', car_model_name: 'R8',
      parts_attributes: [
        { type: 'Wheel', manufacturer: 'Michelin', model: 'X100', price: 500,
          photo_attributes: {
            image_id: 'dummy',
            image_content_type: 'image/jpeg',
            image_size: 123_456,
            image_filename: 'part.jpg'
          } },
        { type: 'Wheel', manufacturer: 'Michelin', model: 'X100', price: 200 }
      ]
    } }
    assert_response :created
    car = user.cars.last
    assert_equal 2, car.parts.count
    assert_equal 700, car.parts.sum(:price)
    assert car.parts.first.photo.present?
  end
end
