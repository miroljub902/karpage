ActiveAdmin.register Car do
  menu priority: 20

  actions :all, except: %i(new)

  filter :featured_order_present, as: :select, collection: [['Yes', '1'], ['No', nil]], label: 'Featured'
  filter :make
  filter :model
  filter :year
  filter :description

  member_action :toggle_featured, method: :put do
    resource.toggle_featured!
    notice = resource.featured? ? "#{resource} featured in position ##{resource.featured_order}" : "#{resource} un-featured"
    redirect_to admin_cars_path, notice: notice
  end

  index do
    selectable_column
    column :car, sortable: 'slug' do |car|
      link_to car, admin_car_path(car.id)
    end
    column :description
    column :user do |car|
      link_to car.user, [:admin, car.user]
    end
    column :featured, sortable: 'featured_order' do |car|
      status_tag 'Yes' if car.featured?
    end

    actions defaults: false do |car|
      label = car.featured? ? 'Unfeature' : 'Feature'
      item label, toggle_featured_admin_car_path(car.id), class: 'member_link', method: :put
      item 'Edit', edit_admin_car_path(car.id), class: 'member_link'
      item 'Delete', admin_car_path(car.id), method: :delete, data: { confirm: 'Are you sure you want to delete this?' }, class: 'member_link'
    end
  end

  show do
    attributes_table do
      row :featured do |user|
        if user.featured?
          "Featured in position ##{user.featured_order}"
        else
          status_tag 'No'
        end
      end
      row :make
      row :model
      row :year
      row :page do |car|
        link_to car.slug, profile_car_path(car.user, car), target: '_blank'
      end
      row :description
      row :hits
    end

    panel 'Photos' do
      if car.photos.empty?
        p 'No photos'
      else
        ul class: 'car-photos' do
          car.photos.each do |photo|
            li do
              link_to edit_admin_photo_path(photo) do
                ix_refile_image_tag photo, :image, auto: 'enhance,format', fit: 'crop', w: 100, h: 100, size: '100x100'
              end
            end
          end
        end
      end
    end

    panel 'Comments' do
      if car.comments.empty?
        p 'No comments'
      else
        table_for car.comments do
          column '' do |comment|
            link_to I18n.l(comment.created_at.to_date, format: :long), [:admin, comment]
          end
          column :comment do |comment|
            simple_format comment.body
          end
        end
      end
    end
  end

  permit_params :model_id, :year, :description, :featured_order

  form partial: 'form'

  controller do
    def update
      super location: admin_cars_path
    end

    def edit_resource_path(resource)
      edit_admin_car_path resource.id
    end

    def resource_path(resource)
      admin_car_path resource.id
    end
  end
end
