# frozen_string_literal: true

# rubocop:disable Rails/Output
ActiveAdmin.register User do
  menu priority: 10

  filter :featured_order_present, as: :select, collection: [%w[Yes 1], ['No', nil]], label: 'Featured'
  filter :email, as: :string
  filter :name
  filter :login, as: :string
  filter :location
  filter :current_login_at
  filter :last_login_at
  filter :created_at
  filter :updated_at

  member_action :toggle_featured, method: :put do
    resource.toggle_featured!
    notice = if resource.featured?
               "#{resource} featured in position ##{resource.featured_order}"
             else
               "#{resource} un-featured"
             end
    redirect_to admin_users_path, notice: notice
  end

  index do
    selectable_column
    column :avatar do |user|
      ix_refile_image_tag user, :avatar, auto: 'enhance,format', fit: 'crop', w: 50, h: 50, size: '50x50'
    end
    column :login do |user|
      link_to user.login.presence || '<no login>', admin_user_path(user.id)
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
      item label, toggle_featured_admin_user_path(user.id), class: 'member_link', method: :put
      item 'Edit', edit_admin_user_path(user.id), class: 'member_link'
      item 'Delete',
           admin_user_path(user.id),
           method: :delete,
           data: { confirm: 'Are you sure you want to delete this?' },
           class: 'member_link'
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
        ix_refile_image_tag user, :avatar, auto: 'enhance,format', fit: 'crop', w: 100, h: 100, size: '100x100'
      end
      row :profile_background do |user|
        ix_refile_image_tag user,
                            :profile_background,
                            auto: 'enhance,format', fit: 'crop', w: 300, h: 100, size: '300x100'
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
            label = if car.first_car?
                      'First Car'
                    elsif car.current_car?
                      'Current Car'
                    elsif car.past_car?
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
            ix_refile_image_tag post, :photo, auto: 'enhance,format', fit: 'crop', w: 50, h: 50, size: '50x50'
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
              column :cars, &:cars_count
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
              column :cars, &:cars_count
            end
          end
        end
      end
    end
  end

  permit_params :email, :name, :login, :avatar, :profile_background, :description, :link, :location, :admin,
                :featured_order

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
    def scoped_collection
      end_of_association_chain.cars_count
    end

    def find_resource
      User.find_by(id: params[:id]) || User.find_by!(login: params[:id])
    end

    def edit_resource_path(resource)
      edit_admin_user_path resource.id
    end

    def resource_path(resource)
      admin_user_path resource.id
    end
  end
end
