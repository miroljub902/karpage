require 'test_helper'

class NavCellTest < Cell::TestCase
  test "show" do
    html = cell("nav").(:show)
    assert html.match /<p>/
  end


end
