class PostDecorator < Draper::Decorator
  delegate_all
  decorates_association :user
end
