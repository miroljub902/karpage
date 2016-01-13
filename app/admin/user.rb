ActiveAdmin.register User do
  menu priority: 10

  filter :featured_order_present, as: :select, collection: [['Yes', '1'], ['No', nil]], label: 'Featured'
  filter :email
  filter :name
  filter :login
  filter :location
  filter :current_login_at
  filter :last_login_at
  filter :created_at
  filter :updated_at

  member_action :toggle_featured, method: :put do
    resource.toggle_featured!
    notice = resource.featured? ? "#{resource} featured in position ##{resource.featured_order}" : "#{resource} un-featured"
    redirect_to admin_users_path, notice: notice
  end

  index do
    selectable_column
    column :avatar do |user|
      attachment_image_tag user, :avatar, :fit, 50, 50, size: '50x50'
    end
    column :login do |user|
      link_to user.login.presence || '<no login>', admin_user_path(user)
    end
    column :name
    column :email
    column 'Member Since' do |user|
      I18n.l user.created_at.to_date, format: :long
    end
    column :location
    column :featured do |user|
      status_tag 'Yes' if user.featured?
    end
    actions defaults: false do |user|
      label = user.featured? ? 'Unfeature' : 'Feature'
      item label, toggle_featured_admin_user_path(user), class: 'member_link', method: :put
      item 'Edit', edit_admin_user_path(user), class: 'member_link'
      item 'Delete', admin_user_path(user), method: :delete, data: { confirm: 'Are you sure you want to delete this?' }, class: 'member_link'
    end
  end

  show do
    attributes_table do
      row :id
      row :featured do |user|
        if user.featured?
          "Featured in position ##{user.featured_order}"
        else
          status_tag 'No'
        end
      end
      row :avatar do |user|
        attachment_image_tag user, :avatar, :fit, 100, 100, size: '100x100'
      end
      row :profile_background do |user|
        attachment_image_tag user, :profile_background, :fit, 300, 100, size: '300x100'
      end
      row :login do |user|
        link_to user, profile_path(user.login), target: '_blank' if user.login.present?
      end
      row :name
      row :email
      row :description
      row :location
      row :link do |user|
        link_to user.link, user.link, target: '_blank'
      end
      row 'Member Since' do |user|
        I18n.l user.created_at.to_date, format: :long
      end
      row :login_count
      row :failed_login_count
      row :last_request_at
      row :last_login_at
    end

    panel 'Cars' do
      if user.cars.empty?
        p 'No cars'
      else
        table_for user.cars do
          column :car do |car|
            link_to car, admin_car_path(car.id)
          end
          column :description
          column :type do |car|
            label = if car.first?
              'First Car'
            elsif car.current?
              'Current Car'
            elsif car.past?
              'Past Car'
            end
            status_tag label if label
          end
          column :created_at do |car|
            I18n.l car.created_at.to_date, format: :long
          end
          column :hits
        end
      end
    end

    panel 'Posts' do
      if user.posts.empty?
        p 'No posts'
      else
        table_for user.posts do
          column :photo do |post|
            attachment_image_tag post, :photo, :fit, 50, 50, size: '50x50'
          end
          column :created_at do |post|
            link_to I18n.l(post.created_at.to_date, format: :long), [:admin, post]
          end
          column :body do |post|
            truncate(post.body, length: 200)
          end
          column :views
        end
      end
    end

    panel 'Comments' do
      if user.comments.empty?
        p 'No comments'
      else
        table_for user.comments do
          column :created_at do |comment|
            link_to I18n.l(comment.created_at.to_date, format: :long), admin_user_comment_path(comment)
          end
          column 'Commented on' do |comment|
            link_to comment.commentable, admin_car_path(comment.commentable_id)
          end
          column :comment do |comment|
            truncate comment.body, length: 100
          end
        end
      end
    end

    columns do
      column do
        panel 'Followers' do
          if user.followers.empty?
            p 'No followers'
          else
            table_for user.followers do
              column '' do |user|
                link_to user, admin_user_path(user)
              end
              column :cars do |user|
                user.cars.count
              end
            end
          end
        end
      end
      column do
        panel 'Following' do
          if user.followees.empty?
            p 'Not following any users'
          else
            table_for user.followees do
              column '' do |user|
                link_to user, admin_user_path(user)
              end
              column :cars do |user|
                user.cars.count
              end
            end
          end
        end
      end
    end
  end

  permit_params :email, :name, :login, :avatar, :profile_background, :description, :link, :location, :admin, :featured_order

  form do |_f|
    inputs do
      input :featured_order, label: 'Featured position'
      input :email
      input :name
      input :login, as: :string
      input :avatar, as: :file
      input :profile_background, as: :file
      input :description
      input :link
      input :location
      input :admin
    end

    actions
  end

  controller do
    def find_resource
      params[:id] =~ /^\d+$/ ? User.find(params[:id]) : User.find_by(login: params[:id])
    end
  end
end
