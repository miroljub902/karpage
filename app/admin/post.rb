# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Post do
  menu priority: 30

  actions :all, except: %i[new]

  scope :all, default: true
  scope :sorted

  filter :body
  filter :views
  filter :created_at

  index do
    selectable_column
    column :photo do |post|
      ix_refile_image_tag post, :photo, auto: 'enhance,format', fit: 'crop', w: 50, h: 50, size: '50x50'
    end
    column :body do |post|
      truncate post.body, length: 100
    end
    column :user
    column :created_at do |post|
      I18n.l post.created_at.to_date, format: :long
    end
    actions
  end

  show do
    attributes_table do
      row :user
      row :photo do |post|
        ix_refile_image_tag post, :photo, auto: 'enhance,format', fit: 'crop', w: 100, h: 100, size: '100x100'
      end
      row :body do |post|
        simple_format post.body
      end
      row :views
      row 'Posted' do |post|
        I18n.l post.created_at.to_date, format: :long
      end
    end
  end

  permit_params :photo, :body

  form do |_f|
    inputs do
      input :photo
      input :body
    end

    actions
  end
end
