ActiveAdmin.register Car do
  menu priority: 20

  actions :all, except: %i(new)

  filter :make
  filter :model
  filter :year
  filter :description

  before_filter do
    Car.class_eval do
      def to_param
        id.to_s
      end
    end
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

    actions defaults: false do |car|
      item 'Edit', edit_admin_car_path(car.id), class: 'member_link'
      item 'Delete', admin_car_path(car.id), method: :delete, data: { confirm: 'Are you sure you want to delete this?' }, class: 'member_link'
    end
  end

  show do
    attributes_table do
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
            li attachment_image_tag photo, :image, :fit, 100, 100, size: '100x100'
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

  permit_params :model_id, :year, :description

  form do |_f|
    inputs do
      input :model
      input :year
      input :description
    end

    actions
  end
end
