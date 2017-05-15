require 'test_helper'
require_relative '../api_controller_test'

class Api::PostsChannelsControllerTest < ApiControllerTest
  setup do
    Post.delete_all
    (Date.new(2017, 5, 14)..Date.new(2017, 5, 20)).each do |day|
      dayname = day.strftime('%A').downcase
      created_at = day.in_time_zone(Time.zone) + 12.hours
      post = Post.create!(body: dayname, created_at: created_at, photo_id: 'dummy', user: users(:john_doe))
      instance_variable_set "@#{dayname}", post
    end
  end

  (Date.new(2017, 5, 14)..Date.new(2017, 5, 20)).each do |day|
    dayname = day.strftime('%A').downcase
    test "retrieves #{dayname} posts" do
      get :show, id: dayname
      assert_response :ok
      assert_equal 1, json_response['posts'].size, "More than 1 post on #{dayname}"
      assert_equal dayname, json_response['posts'].first['body'], "Wrong post returned for #{dayname}"
    end
  end
end
