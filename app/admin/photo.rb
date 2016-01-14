ActiveAdmin.register Photo do
  menu false

  actions :all, except: %i(new show create)

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
      input :rotate, hint: 'Enter a positive or negative angle for manual rotation'
    end

    actions
  end
end
