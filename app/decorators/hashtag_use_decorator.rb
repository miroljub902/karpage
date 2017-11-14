# frozen_string_literal: true

class HashtagUseDecorator < Draper::Decorator
  delegate_all

  decorates_associations :relatable

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def render
    case relatable
    when Post
      h.render 'posts/card', post: relatable
    when Car
      h.render 'user_cars/card', car: relatable
    end
  end
end
