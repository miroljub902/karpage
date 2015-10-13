class HomeController < ApplicationController
  def index
    owners = [%w(John Michael Steven Angelina), %w(Doe Leery Tyler Solano)]
    models = [ 'Mazda CX-7', 'Chevrolet Corvette', 'Bugatti Veyron', 'Ferrari 458', 'Porsche Carrera', 'Lamborghini Aventador' ]
    locations = [ 'Chicago, IL', 'Miami, FL', 'Manhattan, NY', 'Dallas, TX', 'California, LA' ]
    @cars = 5.times.map do
      OpenStruct.new(
        owner: "#{owners.first.sample} #{owners.last.sample}",
        name: "#{rand(15) + 2000} #{models.sample}",
        location: locations.sample
      )
    end
  end
end
