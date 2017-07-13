class UserCarsDecorator
  class << self
    def cars(user)
      cars = user.cars.order(:sorting)
      first_car = cars.detect(&:first?)
      next_car = cars.detect(&:next_car?)
      OpenStruct.new(
        first:   first_car ? UserCarDecorator.new(first_car) : nil,
        current: cars.find_all(&:current?).map { |car| UserCarDecorator.new(car) },
        past:    cars.find_all(&:past?).map { |car| UserCarDecorator.new(car) },
        next_car: next_car ? UserCarDecorator.new(next_car) : nil
      )
    end
  end
end
