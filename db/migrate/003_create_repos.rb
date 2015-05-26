class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string  :name,    null: false
      t.string  :service, null: false
      t.integer :hoster,  null: false
      t.integer :source,  null: true
    end
    add_index :repos, :name, unique: true
  end
end