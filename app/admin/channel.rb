# frozen_string_literal: true

ActiveAdmin.register PostChannel, as: 'Channels' do
  menu parent: 'Posts'

  filter :name

  index do
    selectable_column
    column :ordering
    column :name do |channel|
      link_to channel, admin_channel_path(channel)
    end
    column :thumb do |channel|
      ix_refile_image_tag channel, :thumb, auto: 'enhance,format', fit: 'crop', w: 150, h: 70, size: '150x70'
    end

    actions defaults: false do |channel|
      item 'Edit', edit_admin_channel_path(channel.id), class: 'member_link'
      item 'Delete',
           admin_channel_path(channel.id),
           method: :delete,
           data: { confirm: 'Are you sure you want to delete this?' },
           class: 'member_link'
    end
  end

  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :ordering
      row :active
      row :image do |channel|
        ix_refile_image_tag channel, :image, auto: 'enhance,format', fit: 'crop', w: 150, h: 70, size: '150x70'
      end
      row :thumb do |channel|
        ix_refile_image_tag channel, :thumb, auto: 'enhance,format', fit: 'crop', w: 150, h: 70, size: '150x70'
      end
    end
  end

  permit_params :name, :description, :image, :thumb, :ordering, :active

  form do |_f|
    inputs do
      input :name
      input :description
      input :ordering
      input :active, as: :boolean
      input :image, as: :file
      input :thumb, as: :file
    end

    actions
  end
end
