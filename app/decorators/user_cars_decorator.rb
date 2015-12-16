class UserCarsDecorator
  class << self
    def cars(user)
      cars = user.cars
      first_car = cars.detect(&:first?)
      OpenStruct.new(
        first:   first_car ? UserCarDecorator.new(first_car) : nil,
        current: cars.find_all(&:current?).sort_by { |car| car.created_at }.reverse.map { |car| UserCarDecorator.new(car) },
        past:    cars.find_all(&:past?).sort_by { |car| car.created_at }.reverse.map { |car| UserCarDecorator.new(car) }
      )
    end
  end
end
