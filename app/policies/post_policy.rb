# frozen_string_literal: true

class PostPolicy < ApplicationPolicy
  def max_photos
    20
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
