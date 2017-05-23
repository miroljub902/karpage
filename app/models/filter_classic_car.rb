class FilterClassicCar < Filter
  def search
    Car.has_photos.owner_has_login.joins(:make, :model).where('year <= 1980')
  end
end
