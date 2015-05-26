# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 6) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "credential_rights", force: :cascade do |t|
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "user_id",                      null: false
    t.integer  "credential_id",                null: false
    t.boolean  "owner",         default: true, null: false
  end

  create_table "credentials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "service",    null: false
    t.string   "uid",        null: false
    t.text     "data",       null: false
  end

  create_table "repos", force: :cascade do |t|
    t.string  "name",    null: false
    t.string  "service", null: false
    t.integer "hoster",  null: false
    t.integer "source"
  end

  add_index "repos", ["name"], name: "index_repos_on_name", unique: true, using: :btree

  create_table "repos_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "repo_id"
    t.integer  "user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "user_id",                   null: false
    t.string   "token",                     null: false
    t.boolean  "active",     default: true, null: false
    t.text     "details"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "username",      limit: 120, null: false
    t.string   "password_hash", limit: 128
  end

  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
