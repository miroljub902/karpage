# frozen_string_literal: true

ActiveAdmin.register Photo do
  menu false

  actions :all, except: %i[new show create]

  controller do
    def update
      location = case resource.attachable_type
                 when 'Car'
                   admin_car_path(resource.attachable.id)
                 else
                   [:admin, resource.attachable]
                 end
      super location: location
    end
  end

  permit_params :rotate

  form do |_f|
    inputs do
      input :rotate, hint: 'Enter an angle (0-359) for manual rotation (counter-clockwise)'
    end

    actions
  end
end
