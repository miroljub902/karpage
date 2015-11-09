class HomeController < ApplicationController
  def index
    @cars = Car.popular.limit(6)
  end
end
