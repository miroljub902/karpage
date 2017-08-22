# frozen_string_literal: true

class Filter < ActiveRecord::Base
  def search
    words = self.words.presence || name
    sql = words.split(',').map(&:strip).map do |word|
      "cars.slug ILIKE '%#{word}%' OR makes.name ILIKE '%#{word}%' OR models.name ILIKE '%#{word}%'"
    end
    Car.has_photos.owner_has_login.joins(:make, :model).where(sql.join(" OR "))
  end
end
