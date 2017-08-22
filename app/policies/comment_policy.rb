# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def destroy?
    user && (record.user_id == user.id || record.commentable.user_id == user.id)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
