# frozen_string_literal: true

class CreateVideos < ActiveRecord::Migration[5.1]
  def change
    create_table :videos do |t|
      t.references :attachable, polymorphic: true, index: true
      t.jsonb :urls, null: false, default: {}
      t.string :source_id
      t.string :status
      t.string :job_id
      t.string :job_status
      t.string :job_status_detail

      t.timestamps
    end

    add_index :videos, :status
  end
end
