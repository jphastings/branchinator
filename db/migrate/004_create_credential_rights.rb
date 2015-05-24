class CreateCredentialRights < ActiveRecord::Migration
  def change
    create_table :credential_rights do |t|
      t.timestamps null: false
      t.integer :user_id, null: false
      t.integer :credential_id, null: false
      t.boolean :owner, null: false, default: true
    end
  end
end