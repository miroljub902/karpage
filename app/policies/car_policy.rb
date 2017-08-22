# frozen_string_literal: true

class CarPolicy < ApplicationPolicy
  def max_photos
    record.next_car? ? 1 : 20
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
