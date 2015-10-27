class CommentPolicy < ApplicationPolicy
  def destroy?
    record.user_id == user.id || record.commentable.user_id == user.id
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
