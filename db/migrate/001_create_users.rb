class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.timestamps null: false
      t.string :username, limit: 120, null: false
      t.string :password_hash, limit: 128
    end
    add_index :users, :username, unique: true
  end
end