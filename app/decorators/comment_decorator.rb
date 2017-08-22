# frozen_string_literal: true

class CommentDecorator < Draper::Decorator
  delegate_all

  decorates_associations :user
end
