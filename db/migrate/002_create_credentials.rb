class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.timestamps null: false
      t.string :service, null: false
      t.string :uid, null: false
      t.text   :data, null: false
    end
    # add_index :users, [:username, :uid], unique: true
  end
end