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

ActiveRecord::Schema.define(version: 20150807164316) do

  create_table "accounts", force: :cascade do |t|
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

  create_table "airwatch_groups", force: :cascade do |t|
    t.integer  "airwatch_instance_id"
    t.integer  "company_id"
    t.string   "text_id"
    t.string   "numeric_id"
    t.string   "kind"
    t.datetime "deleted_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "airwatch_groups", ["deleted_at"], name: "index_airwatch_groups_on_deleted_at"

  create_table "airwatch_instances", force: :cascade do |t|
    t.string   "group_name"
    t.string   "group_region"
    t.string   "api_key"
    t.string   "host"
    t.string   "user"
    t.string   "password"
    t.string   "parent_group_id"
    t.text     "admin_roles"
    t.datetime "deleted_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "security_pin"
  end

  add_index "airwatch_instances", ["deleted_at"], name: "index_airwatch_instances_on_deleted_at"

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "companies", ["deleted_at"], name: "index_companies_on_deleted_at"

  create_table "customers", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "customers", ["company_id"], name: "index_customers_on_company_id"
  add_index "customers", ["deleted_at"], name: "index_customers_on_deleted_at"

  create_table "directories", force: :cascade do |t|
    t.string   "host"
    t.string   "port"
    t.string   "api_key"
    t.datetime "deleted_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "use_ssl",    default: false, null: false
  end

  add_index "directories", ["deleted_at"], name: "index_directories_on_deleted_at"

  create_table "directory_prolongations", force: :cascade do |t|
    t.integer  "user_integration_id"
    t.integer  "user_id"
    t.string   "reason"
    t.date     "expiration_date_old"
    t.date     "expiration_date_new"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "directory_prolongations", ["user_id"], name: "index_directory_prolongations_on_user_id"
  add_index "directory_prolongations", ["user_integration_id"], name: "index_directory_prolongations_on_user_integration_id"

  create_table "domains", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "profile_id"
    t.string   "name"
    t.integer  "status",     default: 0, null: false
    t.integer  "limit"
    t.integer  "user_role",  default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "domains", ["company_id"], name: "index_domains_on_company_id"
  add_index "domains", ["deleted_at"], name: "index_domains_on_deleted_at"
  add_index "domains", ["profile_id"], name: "index_domains_on_profile_id"

  create_table "google_apps_instances", force: :cascade do |t|
    t.string   "group_name"
    t.string   "group_region"
    t.text     "key_base64"
    t.string   "key_password"
    t.string   "initial_password"
    t.string   "service_account"
    t.string   "act_on_behalf"
    t.datetime "deleted_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "google_apps_instances", ["deleted_at"], name: "index_google_apps_instances_on_deleted_at"

  create_table "horizon_air_instances", force: :cascade do |t|
    t.string   "group_name"
    t.string   "group_region"
    t.string   "instance_url"
    t.string   "instance_port"
    t.string   "api_key"
    t.datetime "deleted_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "horizon_air_instances", ["deleted_at"], name: "index_horizon_air_instances_on_deleted_at"

  create_table "horizon_instances", force: :cascade do |t|
    t.string   "rds_group_name"
    t.string   "desktops_group_name"
    t.string   "view_group_name"
    t.string   "group_region"
    t.string   "api_host"
    t.string   "api_port"
    t.string   "api_key"
    t.datetime "deleted_at"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "horizon_instances", ["deleted_at"], name: "index_horizon_instances_on_deleted_at"

  create_table "integrations", force: :cascade do |t|
    t.string   "name"
    t.string   "domain"
    t.integer  "directory_id"
    t.integer  "office365_instance_id"
    t.integer  "google_apps_instance_id"
    t.integer  "airwatch_instance_id"
    t.integer  "horizon_air_instance_id"
    t.integer  "horizon_view_instance_id"
    t.integer  "horizon_rds_instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "integrations", ["airwatch_instance_id"], name: "index_integrations_on_airwatch_instance_id"
  add_index "integrations", ["deleted_at"], name: "index_integrations_on_deleted_at"
  add_index "integrations", ["directory_id"], name: "index_integrations_on_directory_id"
  add_index "integrations", ["google_apps_instance_id"], name: "index_integrations_on_google_apps_instance_id"
  add_index "integrations", ["horizon_air_instance_id"], name: "index_integrations_on_horizon_air_instance_id"
  add_index "integrations", ["horizon_rds_instance_id"], name: "index_integrations_on_horizon_rds_instance_id"
  add_index "integrations", ["horizon_view_instance_id"], name: "index_integrations_on_horizon_view_instance_id"
  add_index "integrations", ["office365_instance_id"], name: "index_integrations_on_office365_instance_id"

  create_table "invitations", force: :cascade do |t|
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.datetime "sent_at"
    t.integer  "potential_seats"
    t.datetime "deleted_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "invitations", ["deleted_at"], name: "index_invitations_on_deleted_at"
  add_index "invitations", ["from_user_id"], name: "index_invitations_on_from_user_id"
  add_index "invitations", ["to_user_id"], name: "index_invitations_on_to_user_id"

  create_table "office365_instances", force: :cascade do |t|
    t.string   "group_name"
    t.string   "group_region"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "tenant_id"
    t.string   "resource_id"
    t.datetime "deleted_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "office365_instances", ["deleted_at"], name: "index_office365_instances_on_deleted_at"

  create_table "partners", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "vmware_partner_id"
    t.string   "contact_name"
    t.string   "contact_email"
    t.string   "contact_phone"
    t.datetime "deleted_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "partners", ["company_id"], name: "index_partners_on_company_id"
  add_index "partners", ["deleted_at"], name: "index_partners_on_deleted_at"

  create_table "profile_integrations", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "integration_id"
    t.integer  "authentication_priority",     default: 100,   null: false
    t.boolean  "allow_sharing",               default: false, null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "office365_default_status"
    t.integer  "google_apps_default_status"
    t.integer  "airwatch_default_status"
    t.integer  "horizon_air_default_status"
    t.integer  "horizon_view_default_status"
    t.integer  "horizon_rds_default_status"
  end

  add_index "profile_integrations", ["integration_id"], name: "index_profile_integrations_on_integration_id"
  add_index "profile_integrations", ["profile_id", "integration_id"], name: "index_profile_integrations_on_profile_id_and_integration_id", unique: true
  add_index "profile_integrations", ["profile_id"], name: "index_profile_integrations_on_profile_id"

  create_table "profiles", force: :cascade do |t|
    t.string   "name"
    t.string   "home_template"
    t.string   "support_email"
    t.string   "group_name"
    t.string   "group_region"
    t.boolean  "supports_vidm",             default: true,  null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "requires_verification",     default: false, null: false
    t.boolean  "airwatch_admins_supported", default: false, null: false
  end

  add_index "profiles", ["deleted_at"], name: "index_profiles_on_deleted_at"

  create_table "registration_codes", force: :cascade do |t|
    t.integer  "user_role",           default: 0,  null: false
    t.integer  "user_validity",       default: 30, null: false
    t.string   "code",                             null: false
    t.integer  "total_registrations", default: 0,  null: false
    t.date     "valid_from"
    t.date     "valid_to"
    t.datetime "deleted_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "profile_id"
  end

  add_index "registration_codes", ["deleted_at"], name: "index_registration_codes_on_deleted_at"

  create_table "user_integrations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "integration_id"
    t.string   "username"
    t.date     "directory_expiration_date",             null: false
    t.integer  "directory_status",          default: 0, null: false
    t.integer  "horizon_air_status",        default: 0, null: false
    t.integer  "horizon_rds_status",        default: 0, null: false
    t.integer  "horizon_view_status",       default: 0, null: false
    t.integer  "airwatch_status",           default: 0, null: false
    t.integer  "office365_status",          default: 0, null: false
    t.integer  "google_apps_status",        default: 0, null: false
    t.integer  "airwatch_user_id"
    t.integer  "airwatch_admin_user_id"
    t.integer  "airwatch_group_id"
    t.datetime "deleted_at"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "user_integrations", ["airwatch_admin_user_id"], name: "index_user_integrations_on_airwatch_admin_user_id"
  add_index "user_integrations", ["airwatch_group_id"], name: "index_user_integrations_on_airwatch_group_id"
  add_index "user_integrations", ["airwatch_user_id"], name: "index_user_integrations_on_airwatch_user_id"
  add_index "user_integrations", ["deleted_at"], name: "index_user_integrations_on_deleted_at"
  add_index "user_integrations", ["integration_id"], name: "index_user_integrations_on_integration_id"
  add_index "user_integrations", ["user_id", "integration_id"], name: "index_user_integrations_on_user_id_and_integration_id", unique: true
  add_index "user_integrations", ["user_id"], name: "index_user_integrations_on_user_id"

  create_table "user_requests", force: :cascade do |t|
    t.string  "ip"
    t.date    "date"
    t.integer "hour"
    t.integer "quantity"
  end

  add_index "user_requests", ["date", "hour"], name: "index_user_requests_on_date_and_hour"

  create_table "users", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "profile_id"
    t.integer  "registration_code_id"
    t.integer  "authentication_integration_id"
    t.string   "email",                                     null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "avatar"
    t.string   "country_code"
    t.string   "phone"
    t.integer  "role",                          default: 0, null: false
    t.integer  "status",                        default: 0, null: false
    t.string   "job_title"
    t.integer  "invitations_used",              default: 0, null: false
    t.integer  "total_invitations",             default: 5, null: false
    t.string   "home_region"
    t.date     "airwatch_eula_accept_date"
    t.datetime "last_authorized_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "verification_token"
  end

  add_index "users", ["authentication_integration_id"], name: "index_users_on_authentication_integration_id"
  add_index "users", ["company_id"], name: "index_users_on_company_id"
  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at"
  add_index "users", ["email"], name: "index_users_on_email"
  add_index "users", ["profile_id"], name: "index_users_on_profile_id"
  add_index "users", ["registration_code_id"], name: "index_users_on_registration_code_id"

end
