class CreateReposUsers < ActiveRecord::Migration
  def change
    create_table :repos_users do |t|
      t.integer :repo_id
      t.integer :user_id
    end
  end
end