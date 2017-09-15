# frozen_string_literal: true

module UniqueViolationGuard
  extend ActiveSupport::Concern

  def save(*)
    super
  rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique
    errors.add :base, "Duplicate #{model_name.human.downcase}"
    false
  rescue ActiveRecord::StatementInvalid => e
    # Work around race condition
    raise unless e.original_exception.is_a?(PG::InFailedSqlTransaction)
    errors.add :base, 'Unexpected error, please try again later'
    false
  end
end
