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
end
