class UserCarsDecorator
  class << self
    def cars(user)
      cars = user.cars
      OpenStruct.new(
        first:      UserCarDecorator.new(cars.detect(&:first?)),
        current:    cars.find_all(&:current?).map { |car| UserCarDecorator.new(car) },
        past:       cars.find_all(&:past?).map { |car| UserCarDecorator.new(car) }
      )
    end
  end
end
