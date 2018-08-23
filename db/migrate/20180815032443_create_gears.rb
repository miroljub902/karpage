class CreateGears < ActiveRecord::Migration[5.1]
  def self.up
    create_table :gears do |t|
      t.string :name


      t.timestamps
    end
  end

  def self.down
    drop_table :gears
  end
end
