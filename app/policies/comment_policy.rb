# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def destroy?
    user && (admin_user? || record.user_id == user.id || record.commentable.user_id == user.id)
  end

  def reply?
    user.present? && record.commentable_type != 'Comment'
  end

  class Scope < Scope
    def resolve
      admin_user? ? scope : user.comments
    end
  end
end
