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

ActiveRecord::Schema.define(version: 20111013050837) do

  create_table "accounts", force: true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["account_id"], name: "index_accounts_on_account_id"
  add_index "accounts", ["name"], name: "index_accounts_on_name"

  create_table "accounts_users", id: false, force: true do |t|
    t.integer "account_id", null: false
    t.integer "user_id",    null: false
  end

  add_index "accounts_users", ["account_id", "user_id"], name: "index_accounts_users_on_account_id_and_user_id"

  create_table "members", force: true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "members", ["account_id"], name: "index_members_on_account_id"
  add_index "members", ["user_id"], name: "index_members_on_user_id"

  create_table "posts", force: true do |t|
    t.integer  "account_id"
    t.integer  "member_id"
    t.integer  "zine_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["account_id"], name: "index_posts_on_account_id"
  add_index "posts", ["member_id"], name: "index_posts_on_member_id"
  add_index "posts", ["zine_id"], name: "index_posts_on_zine_id"

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "team_assets", force: true do |t|
    t.integer  "account_id"
    t.integer  "member_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "team_assets", ["account_id"], name: "index_team_assets_on_account_id"
  add_index "team_assets", ["member_id"], name: "index_team_assets_on_member_id"
  add_index "team_assets", ["team_id"], name: "index_team_assets_on_team_id"

  create_table "teams", force: true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teams", ["account_id"], name: "index_teams_on_account_id"

  create_table "users", force: true do |t|
    t.string   "email",                        default: "",    null: false
    t.string   "encrypted_password",           default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "skip_confirm_change_password", default: false
    t.integer  "account_id"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "zines", force: true do |t|
    t.integer  "account_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "zines", ["account_id"], name: "index_zines_on_account_id"
  add_index "zines", ["team_id"], name: "index_zines_on_team_id"

end
