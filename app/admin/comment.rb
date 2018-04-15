# frozen_string_literal: true

ActiveAdmin.register Comment, as: 'UserComment' do
  menu priority: 40

  actions :all, except: %i[new]

  filter :body
  filter :created_at

  index do
    selectable_column
    column :subject, sortable: 'commentable_id' do |comment|
      "#{comment.commentable.class}: #{link_to(comment.commentable, admin_car_path(comment.commentable))}".html_safe
    end
    column 'Comment' do |comment|
      truncate comment.body, length: 100
    end
    column :user do |comment|
      link_to Admin::UserDecorator.new(comment.user), admin_user_path(comment.user_id)
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :car do |comment|
        link_to comment.commentable, admin_car_path(comment.commentable)
      end
      row 'Comment' do |comment|
        simple_format comment.body
      end
      row :user
      row :created_at
    end
  end

  permit_params :body

  form do |_f|
    inputs do
      input :body, label: 'Comment'
    end

    actions
  end
end
