class Api::FiltersController < ApiController
  def index
    @filters = Filter.all
  end
end
