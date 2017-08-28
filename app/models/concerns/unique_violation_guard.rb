# frozen_string_literal: true

module UniqueViolationGuard
  extend ActiveSupport::Concern

  def save(*)
    super
  rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique
    errors.add :base, "Duplicate #{model_name.human.downcase}"
    false
  end
end
