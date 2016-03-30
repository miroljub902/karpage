require 'test_helper'
require_relative '../api_controller_test'

class Api::ReportsControllerTest < ApiControllerTest
  test 'can report user' do
    user = users(:john_doe)
    fiend = users(:friend)
    authorize_user user
    assert_difference 'Report.count' do
      post :create, profile_id: fiend.id, reportable_type: 'User', report: { reason: 'Test' }
      assert_response :created
    end
    assert_equal 'Test', Report.last.reason
  end

  test 'can report car' do
    user = users(:john_doe)
    car = cars(:first)
    car.user = users(:friend)
    car.save!
    authorize_user user
    assert_difference 'Report.count' do
      post :create, car_id: car.id, reportable_type: 'Car', report: { reason: 'Car' }
      assert_response :created
    end
    assert_equal 'Car', Report.last.reason
  end

  test 'can report post' do
    user = users(:john_doe)
    fiend = users(:friend)
    the_post = fiend.posts.create! photo_id: 'dummy', body: 'dummy'
    authorize_user user
    assert_difference 'Report.count' do
      post :create, post_id: the_post.id, reportable_type: 'Post', report: { reason: 'Post' }
      assert_response :created
    end
    report = Report.last
    assert_equal 'Post', report.reason
    assert_equal report.reportable, the_post
  end
end
