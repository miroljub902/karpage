class UserCarsDecorator
  class << self
    def cars(user)
      cars = user.cars
      OpenStruct.new(
        first:      cars.find_all(&:first?),
        current:    cars.find_all(&:current?),
        past:       cars.find_all(&:past?),
        wished_for: [],
        next_car:   []
      )
    end
  end
end
