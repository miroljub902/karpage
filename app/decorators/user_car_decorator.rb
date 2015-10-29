class UserCarDecorator < Draper::Decorator
  delegate_all

  decorates_associations :user

  def comments
    model.comments.sorted.decorate
  end
end
