ActiveAdmin.register Report do
  menu priority: 50
  actions :all, except: [:update, :edit]
  filter :reportable_type, as: :select, collection: [['User', 'User'], ['Car', "Car"], ["Post", "Post"]], label: 'Type'

  index do
    selectable_column
    column :object do |report|
      case report.reportable_type
      when "User"
        link_to report.reportable, admin_user_path(report.reportable)
      when "Car"
        link_to report.reportable, admin_car_path(report.reportable_id)
      when "Post"
        link_to truncate(report.reportable.body, length: 30), admin_post_path(report.reportable)
      end
    end
    column :user do |report|
      link_to report.user, admin_user_path(report.user)
    end
    column :reason do |report|
      report.reason
    end
    actions
  end
end
