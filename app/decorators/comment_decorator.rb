class CommentDecorator < Draper::Decorator
  delegate_all

  decorates_associations :user
end
