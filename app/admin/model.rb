# frozen_string_literal: true

ActiveAdmin.register Model do
  menu parent: 'Cars'

  config.sort_order = 'makes.name_asc'

  filter :name
  filter :official
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :make, sortable: 'makes.name' do |model|
      link_to model.make, admin_make_path(model.make)
    end
    column :name do |model|
      safe_join([
                  link_to(model, admin_model_path(model.id)),
                  " (#{link_to 'Trims', admin_trims_path(q: { model_id_equals: model.id })})".html_safe
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
      row :make
      row :name
      row :official do
        status_tag model.official
      end
      row :trims do
        link_to "#{model.trims.count} trims", admin_trims_path(q: { model_id_equals: model.id })
      end
      row :created_at
      row :updated_at
    end
  end

  permit_params :name, :official, :make_id

  form do |_f|
    inputs do
      input :make, collection: Make.official.order(name: :asc)
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

    def resource_path(model)      admin_model_path(model.id)      end
    def resource_url(model)       admin_model_url(model.id)       end
    def edit_resource_path(model) edit_admin_model_path(model.id) end

    def scoped_collection
      scope = end_of_association_chain
              .select('models.*, COUNT(cars.id) AS cars_count')
              .joins(:make)
              .preload(:make)
              .joins('LEFT OUTER JOIN cars ON cars.model_id = models.id')
              .group('makes.id, models.id')
      scope = scope.official unless @filtered
      scope
    end
  end
end
