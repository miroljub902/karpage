module UniqueViolationGuard
  extend ActiveSupport::Concern

  included do

  end

  def save(*)
    super
  rescue PG::UniqueViolation
    errors.add :base, "Duplicate #{model_name.human.downcase}"
    false
  end
end
