class CreateCredentialsUsers < ActiveRecord::Migration
  def change
    create_table :credentials_users do |t|
      t.integer :user_id
      t.integer :credential_id
    end
  end
end