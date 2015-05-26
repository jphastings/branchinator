class CreateReposUsers < ActiveRecord::Migration
  def change
    create_table :repos_users do |t|
      t.timestamps null: false
      t.integer :repo_id
      t.integer :user_id
    end
  end
end