# frozen_string_literal: true

class Admin::UserDecorator < AdminDecorator
  decorates User

  def to_s
    object.to_s.presence || email.presence || id
  end
end
