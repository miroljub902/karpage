class UserDecorator < Draper::Decorator
  delegate_all

  def initials
    model.name.to_s.split(' ')[0..1].map { |n| n.first.upcase }.join.presence || '?'
  end
end
