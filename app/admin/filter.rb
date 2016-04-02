ActiveAdmin.register Filter do
  menu priority: 60
  permit_params :name, :words
  actions :all, except: [:show]
end