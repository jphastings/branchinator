class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string  :name, null: false
      t.integer :host,   null: false
      t.integer :source, null: true
    end
    add_index :repos, :name, unique: true
  end
end