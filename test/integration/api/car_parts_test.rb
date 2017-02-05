require 'test_helper'

class Api::CarPartsTest < ActionDispatch::IntegrationTest
  setup do
    mock_request 's3'
    @user = users(:john_doe)
    @car = cars(:current)
    @user.cars << @car
    @car.reload
    @part_params = {
      car_part: {
        type: 'Wheel', manufacturer: 'Michelin', model: 'F500', price: 500,
        photo_attributes: {
          image_id: 'dummy', image_content_type: 'image/jpeg', image_size: 123456, image_filename: 'part.jpg'
        }
      }
    }
  end

  test 'user can create a part for a car' do
    assert_difference '@car.parts.count' do
      post api_car_parts_url(@car.id, format: :json), @part_params, 'Authorization' => @user.access_token
      assert_response :created
    end
  end

  test 'can add a photo' do
    post api_car_parts_url(@car.id, format: :json), @part_params, 'Authorization' => @user.access_token
    photo = @car.parts.first.photo
    assert !photo.nil?
  end

  test 'user can update a part for a car' do
    part = @car.parts.create! @part_params[:car_part]
    params = { car_part: { type: 'Changed' } }
    put api_car_part_url(@car.id, part.id, format: :json), params, 'Authorization' => @user.access_token
    assert_equal 'Changed', part.reload.type
  end

  test 'user can remove a part from a car' do
    part = @car.parts.create! @part_params[:car_part]
    delete api_car_part_url(@car.id, part.id, format: :json), {}, 'Authorization' => @user.access_token
    assert_equal 0, @car.parts.count
  end
end
