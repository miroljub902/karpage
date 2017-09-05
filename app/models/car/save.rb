# frozen_string_literal: true

class Car
  class Save < Car
    include ApplicationForm

    attr_accessor :make_name, :car_model_name, :trim_name

    validates :make_name, :car_model_name, presence: true, if: :custom?

    def makes_collection_for_select
      (year ? Make.official_or_with_id(make_id).has_year(year).sorted.pluck(:name, :id) : []).tap do |collection|
        collection.push %w[<OTHER> other]
      end
    end

    %i[make_name car_model_name trim_name].each do |attr|
      define_method "#{attr}=" do |value|
        instance_variable_set "@custom_#{attr}", value.presence
        instance_variable_set "@#{attr}", value
      end
    end

    def custom?
      @custom_make_name || @custom_car_model_name || @custom_trim_name ||
        !make&.official? || !model&.official? || !trim&.official?
    end

    def make_name;      @make_name || make&.name;       end
    def car_model_name; @car_model_name || model&.name; end
    def trim_name;      @trim_name || trim&.name;       end

    def save(*)
      assign_or_create_make
      assign_or_create_model
      assign_or_create_trim
      super
    end

    private

    def assign_or_create_make
      # Set make from existing make name or create it
      return if make_name.blank?
      self.make = Make.find_by(slug: make_name.parameterize) ||
                  Make.create(name: make_name, official: false)
    end

    def assign_or_create_model
      # Set model from existing model name or create it
      return unless make && car_model_name.present?
      self.model = make.models.find_by(slug: car_model_name.parameterize) ||
                   make.models.new(name: car_model_name, official: false)
    end

    def assign_or_create_trim
      # Set trim from existing trim name or create it
      return unless model && trim_name.present?
      self.trim = model.trims.find_by(name: trim_name) ||
                   model.trims.new(name: trim_name, year: year, official: false)
    end
  end
end
