# frozen_string_literal: true

ActiveAdmin.register Trim do
  menu parent: 'Cars'

  config.sort_order = 'makes.name_asc, models.name_asc, trims.year_desc, trims.name'

  filter :name
  filter :model_id
  filter :official
  filter :year
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :make, sortable: 'makes.name' do |trim|
      link_to trim.make, admin_make_path(trim.make)
    end
    column :model, sortable: 'models.name' do |trim|
      link_to trim.model, admin_model_path(trim.model_id)
    end
    column :year
    column :name do |trim|
      link_to trim, admin_trim_path(trim.id)
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
      row :model
      row :year
      row :name
      row :official do
        status_tag trim.official
      end
      row :created_at
      row :updated_at
    end
  end

  permit_params :name, :official, :year, :model_id

  form do |f|
    inputs do
      input :make, collection: Make.official_or_with_id(f.object.make_id).order(name: :asc)
      input :model, collection: f.object.make&.models&.official_or_with_id(f.object.model_id)&.order(name: :asc) || []
      input :year
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

    def resource_path(trim)      admin_trim_path(trim.id)      end
    def resource_url(trim)       admin_trim_url(trim.id)       end
    def edit_resource_path(trim) edit_admin_trim_path(trim.id) end

    def scoped_collection
      scope = end_of_association_chain
              .select('trims.*, COUNT(cars.id) AS cars_count')
              .joins(:make, :model)
              .preload(:make, :model)
              .joins('LEFT OUTER JOIN cars ON cars.trim_id = trims.id')
              .group('makes.id, models.id, trims.id')
      scope = scope.official unless @filtered || action_name != 'index'
      scope
    end
  end
end
