class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.timestamps
      t.string :service, limit: 120, null: false
      t.text   :data, null: false
    end
  end
end