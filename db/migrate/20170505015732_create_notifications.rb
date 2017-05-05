class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user, index: true
      t.references :notifiable, polymorphic: true, index: true
      t.references :source, polymorphic: true, index: true
      t.string :type, null: false, index: true
      t.string :message
      t.datetime :sent_at, index: true
      t.string :status_message

      t.timestamps null: false
    end
  end
end
