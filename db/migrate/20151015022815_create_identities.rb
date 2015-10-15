class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.references :user, null: false, index: true
      t.string :provider
      t.string :uid
      t.string :oauth_token
      t.datetime :oauth_expires_at

      t.timestamps null: false
    end

    add_index :identities, %i(user_id provider uid), unique: true
    add_index :identities, %i(provider uid)
  end
end
