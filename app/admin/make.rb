# frozen_string_literal: true

ActiveAdmin.register Make do
  menu parent: 'Cars'

  config.sort_order = 'name_asc'

  filter :name
  filter :official
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :name do |make|
      safe_join([
                  link_to(make, admin_make_path(make)),
                  " (#{link_to 'Models', admin_models_path(q: { make_id_eq: make.id })})".html_safe
                ])
    end
    column :cars, sortable: 'cars_count', &:cars_count
    column :official
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :official do
        status_tag make.official
      end
      row :models do
        link_to "#{make.models.count} models", admin_models_path(q: { make_id_eq: make.id })
      end
      row :created_at
      row :updated_at
    end
  end

  permit_params :name, :official

  form do |_f|
    inputs do
      input :name
      input :official
    end
    actions
  end

  controller do
    before_action only: :index do
      @filtered = params.key?(:q)
      params[:q] = { official: 'true' } if params[:q].blank?
    end

    def find_resource
      end_of_association_chain.find_by!(slug: params[:id])
    end

    def scoped_collection
      scope = end_of_association_chain
              .select('makes.*, COUNT(cars.id) AS cars_count')
              .joins('LEFT OUTER JOIN models ON models.make_id = makes.id')
              .joins('LEFT OUTER JOIN cars ON cars.model_id = models.id')
              .group('makes.id')
      scope = scope.official unless @filtered
      scope
    end
  end
end
