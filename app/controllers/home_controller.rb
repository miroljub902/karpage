class HomeController < ApplicationController
  def index
    if (cookies[:splash] && !browser.device.mobile?) || params[:h] == '1'
      @cars = Car.featured.limit(6).presence || Car.popular.limit(6)
      @users = (User.featured.limit(4).presence || User.by_cars_owned.limit(4)).decorate
    else
      cookies[:splash] = true
      render 'splash', layout: false
    end
  end
end
