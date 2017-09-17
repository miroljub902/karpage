# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :js_config

  # rubocop:disable Metrics/AbcSize
  def index
    raise ActionController::InvalidAuthenticityToken
    force_splash = params[:m] == "1"
    if !force_splash && ((cookies[:splash] && !browser.device.mobile?) || params[:h] == '1')
      @cars = Car.featured.limit(6).presence || Car.popular.limit(6)
      @users = (User.featured.limit(4).presence || User.by_cars_owned.limit(4)).decorate
    else
      cookies[:splash] = true
      render 'splash', layout: false
    end
  end

  def js_config
    respond_to do |format|
      format.js
    end
  end
end
