class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.timestamps null: false
      t.integer :user_id, null: false
      t.string  :token,   null: false
      t.boolean :active,  null: false, default: true
      t.text    :details, null: true
    end
  end
end