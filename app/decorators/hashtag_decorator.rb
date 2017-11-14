# frozen_string_literal: true

class HashtagDecorator < Draper::Decorator
  delegate_all

  def uses_page
    uses
      .select('MAX(id) AS id, MAX(created_at) AS created_at, relatable_id, relatable_type')
      .order('MAX(created_at) DESC')
      .group(:relatable_type, :relatable_id)
      .page(h.params[:page]).per(20)
      .decorate
  end
end
