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

ActiveRecord::Schema.define(version: 20150428174418) do

  create_table "accounts", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "expiration_date"
    t.string   "username"
    t.string   "company"
    t.string   "job_title"
    t.integer  "account_source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "home_region"
    t.string   "uuid"
    t.string   "country_code"
  end

  add_index "accounts", ["deleted_at"], name: "index_accounts_on_deleted_at"

  create_table "airwatch_groups", force: true do |t|
    t.string   "name"
    t.string   "group_id"
    t.integer  "group_id_num"
    t.integer  "parent_id"
    t.string   "domain"
    t.string   "group_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domains", force: true do |t|
    t.string   "name"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "extensions", force: true do |t|
    t.integer  "extended_by"
    t.integer  "recipient"
    t.string   "reason"
    t.datetime "original_expires_at"
    t.datetime "revised_expires_at"
  end

  create_table "feature_toggles", force: true do |t|
    t.string   "name"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", force: true do |t|
    t.integer  "sender_id"
    t.string   "recipient_email"
    t.string   "token"
    t.string   "recipient_username"
    t.string   "recipient_firstname"
    t.string   "recipient_lastname"
    t.string   "recipient_title"
    t.string   "recipient_company"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at"
    t.string   "region"
    t.integer  "potential_seats"
    t.datetime "deleted_at"
    t.boolean  "airwatch_trial"
    t.boolean  "google_apps_trial"
    t.integer  "airwatch_user_id"
    t.datetime "eula_accept_date"
    t.boolean  "acc_expiration_reminder_email"
    t.integer  "reg_code_id"
  end

  add_index "invitations", ["deleted_at"], name: "index_invitations_on_deleted_at"

  create_table "reg_codes", force: true do |t|
    t.string   "code"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.boolean  "status"
    t.integer  "registrations"
    t.integer  "account_type"
    t.integer  "account_validity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "invitation_id"
    t.integer  "invitation_limit"
    t.integer  "role"
    t.string   "display_name"
    t.string   "company"
    t.string   "title"
    t.integer  "invitations_used",  default: 0
    t.integer  "total_invitations", default: 5
    t.string   "avatar"
  end

  add_index "users", ["invitation_id"], name: "index_users_on_invitation_id"

end
