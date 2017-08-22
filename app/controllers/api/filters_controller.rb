# frozen_string_literal: true

class Api::FiltersController < ApiController
  def index
    @filters = Filter.all
  end
end
