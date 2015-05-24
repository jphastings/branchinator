class CreateCredentialsRepos < ActiveRecord::Migration
  def change
    create_table :credentials_repos do |t|
      t.timestamps null: false
      t.integer :repo_id
      t.integer :credential_id
    end
  end
end