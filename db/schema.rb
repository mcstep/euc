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

ActiveRecord::Schema.define(version: 20151124191150) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  add_index "accounts", ["deleted_at"], name: "index_accounts_on_deleted_at", using: :btree

  create_table "airwatch_groups", force: :cascade do |t|
    t.integer  "airwatch_instance_id"
    t.string   "text_id"
    t.string   "numeric_id"
    t.string   "kind"
    t.datetime "deleted_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "airwatch_groups", ["deleted_at"], name: "index_airwatch_groups_on_deleted_at", using: :btree

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
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "security_pin"
    t.string   "display_name"
    t.string   "templates_api_url"
    t.string   "templates_token"
    t.boolean  "use_templates",     default: false, null: false
    t.boolean  "use_admin",         default: false, null: false
    t.boolean  "use_groups",        default: true,  null: false
    t.boolean  "in_maintainance",   default: false, null: false
  end

  add_index "airwatch_instances", ["deleted_at"], name: "index_airwatch_instances_on_deleted_at", using: :btree

  create_table "airwatch_templates", force: :cascade do |t|
    t.integer  "airwatch_instance_id"
    t.string   "domain"
    t.text     "data"
    t.datetime "deleted_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "airwatch_templates", ["deleted_at"], name: "index_airwatch_templates_on_deleted_at", using: :btree

  create_table "blue_jeans_instances", force: :cascade do |t|
    t.string   "group_name"
    t.string   "group_region"
    t.string   "grant_type"
    t.string   "client_id"
    t.string   "client_secret"
    t.integer  "enterprise_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "display_name"
    t.string   "support_emails"
    t.datetime "deleted_at"
    t.boolean  "in_maintainance", default: false, null: false
  end

  create_table "box_instances", force: :cascade do |t|
    t.string   "display_name"
    t.string   "group_name"
    t.string   "group_region"
    t.string   "token_retriever_url"
    t.string   "username"
    t.string   "password"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "access_token"
    t.string   "refresh_token"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "in_maintainance",     default: false, null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "crm_kind",                           default: 0, null: false
    t.integer  "salesforce_opportunity_instance_id"
    t.integer  "salesforce_dealreg_instance_id"
    t.string   "type"
  end

  add_index "companies", ["deleted_at"], name: "index_companies_on_deleted_at", using: :btree

  create_table "customers", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "customers", ["company_id"], name: "index_customers_on_company_id", using: :btree
  add_index "customers", ["deleted_at"], name: "index_customers_on_deleted_at", using: :btree

  create_table "deliveries", force: :cascade do |t|
    t.integer  "profile_id"
    t.string   "from_email",                  null: false
    t.string   "subject",                     null: false
    t.text     "body",                        null: false
    t.datetime "send_at"
    t.integer  "status",       default: 0,    null: false
    t.text     "response"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "adhoc_emails"
    t.boolean  "global",       default: true, null: false
  end

  create_table "directories", force: :cascade do |t|
    t.string   "host"
    t.string   "port"
    t.string   "api_key"
    t.datetime "deleted_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "use_ssl",      default: false, null: false
    t.string   "stats_url"
    t.string   "display_name"
  end

  add_index "directories", ["deleted_at"], name: "index_directories_on_deleted_at", using: :btree

  create_table "directory_prolongations", force: :cascade do |t|
    t.integer  "user_integration_id"
    t.integer  "user_id"
    t.string   "reason"
    t.date     "expiration_date_old"
    t.date     "expiration_date_new"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "send_notification",   default: true, null: false
  end

  add_index "directory_prolongations", ["user_id"], name: "index_directory_prolongations_on_user_id", using: :btree
  add_index "directory_prolongations", ["user_integration_id"], name: "index_directory_prolongations_on_user_integration_id", using: :btree

  create_table "domains", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "profile_id"
    t.string   "name"
    t.integer  "status",            default: 0, null: false
    t.integer  "limit"
    t.integer  "user_role",         default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "total_invitations"
    t.integer  "nomination_id"
    t.integer  "user_validity"
  end

  add_index "domains", ["company_id"], name: "index_domains_on_company_id", using: :btree
  add_index "domains", ["created_at"], name: "index_domains_on_created_at", using: :btree
  add_index "domains", ["deleted_at"], name: "index_domains_on_deleted_at", using: :btree
  add_index "domains", ["profile_id"], name: "index_domains_on_profile_id", using: :btree

  create_table "google_apps_instances", force: :cascade do |t|
    t.string   "group_name"
    t.string   "group_region"
    t.text     "key_base64"
    t.string   "key_password"
    t.string   "initial_password"
    t.string   "service_account"
    t.string   "act_on_behalf"
    t.datetime "deleted_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "display_name"
    t.boolean  "in_maintainance",  default: false, null: false
  end

  add_index "google_apps_instances", ["deleted_at"], name: "index_google_apps_instances_on_deleted_at", using: :btree

  create_table "horizon_air_instances", force: :cascade do |t|
    t.string   "group_name"
    t.string   "group_region"
    t.string   "instance_url"
    t.string   "instance_port"
    t.string   "api_key"
    t.datetime "deleted_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "display_name"
    t.boolean  "in_maintainance", default: false, null: false
  end

  add_index "horizon_air_instances", ["deleted_at"], name: "index_horizon_air_instances_on_deleted_at", using: :btree

  create_table "horizon_instances", force: :cascade do |t|
    t.string   "rds_group_name"
    t.string   "desktops_group_name"
    t.string   "view_group_name"
    t.string   "group_region"
    t.string   "api_host"
    t.string   "api_port"
    t.string   "api_key"
    t.datetime "deleted_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "display_name"
    t.boolean  "in_maintainance",     default: false, null: false
  end

  add_index "horizon_instances", ["deleted_at"], name: "index_horizon_instances_on_deleted_at", using: :btree

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
    t.integer  "blue_jeans_instance_id"
    t.integer  "salesforce_instance_id"
    t.integer  "box_instance_id"
  end

  add_index "integrations", ["airwatch_instance_id"], name: "index_integrations_on_airwatch_instance_id", using: :btree
  add_index "integrations", ["deleted_at"], name: "index_integrations_on_deleted_at", using: :btree
  add_index "integrations", ["directory_id"], name: "index_integrations_on_directory_id", using: :btree
  add_index "integrations", ["google_apps_instance_id"], name: "index_integrations_on_google_apps_instance_id", using: :btree
  add_index "integrations", ["horizon_air_instance_id"], name: "index_integrations_on_horizon_air_instance_id", using: :btree
  add_index "integrations", ["horizon_rds_instance_id"], name: "index_integrations_on_horizon_rds_instance_id", using: :btree
  add_index "integrations", ["horizon_view_instance_id"], name: "index_integrations_on_horizon_view_instance_id", using: :btree
  add_index "integrations", ["office365_instance_id"], name: "index_integrations_on_office365_instance_id", using: :btree

  create_table "invitations", force: :cascade do |t|
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.datetime "sent_at"
    t.integer  "potential_seats"
    t.datetime "deleted_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "crm_kind"
    t.string   "crm_id"
    t.text     "crm_data"
    t.boolean  "crm_fetch_error", default: false, null: false
  end

  add_index "invitations", ["created_at"], name: "index_invitations_on_created_at", using: :btree
  add_index "invitations", ["crm_kind"], name: "index_invitations_on_crm_kind", using: :btree
  add_index "invitations", ["deleted_at"], name: "index_invitations_on_deleted_at", using: :btree
  add_index "invitations", ["from_user_id"], name: "index_invitations_on_from_user_id", using: :btree
  add_index "invitations", ["to_user_id"], name: "index_invitations_on_to_user_id", using: :btree

  create_table "nominations", force: :cascade do |t|
    t.integer  "user_id",                   null: false
    t.string   "company_name",              null: false
    t.string   "domain",                    null: false
    t.integer  "status",        default: 0, null: false
    t.integer  "partner_type",  default: 0, null: false
    t.string   "contact_name",              null: false
    t.string   "contact_email",             null: false
    t.string   "contact_phone"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "partner_id"
  end

  add_index "nominations", ["user_id"], name: "index_nominations_on_user_id", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "office365_instances", force: :cascade do |t|
    t.string   "group_name"
    t.string   "group_region"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "tenant_id"
    t.string   "resource_id"
    t.datetime "deleted_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "license_name"
    t.string   "display_name"
    t.boolean  "in_maintainance", default: false, null: false
  end

  add_index "office365_instances", ["deleted_at"], name: "index_office365_instances_on_deleted_at", using: :btree

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

  add_index "partners", ["company_id"], name: "index_partners_on_company_id", using: :btree
  add_index "partners", ["deleted_at"], name: "index_partners_on_deleted_at", using: :btree

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
    t.integer  "blue_jeans_default_status"
    t.integer  "salesforce_default_status"
    t.integer  "box_default_status"
  end

  add_index "profile_integrations", ["integration_id"], name: "index_profile_integrations_on_integration_id", using: :btree
  add_index "profile_integrations", ["profile_id", "integration_id"], name: "index_profile_integrations_on_profile_id_and_integration_id", unique: true, using: :btree
  add_index "profile_integrations", ["profile_id"], name: "index_profile_integrations_on_profile_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.string   "name"
    t.string   "home_template"
    t.string   "support_email"
    t.string   "group_name"
    t.string   "group_region"
    t.boolean  "supports_vidm",         default: true,  null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "requires_verification", default: false, null: false
    t.boolean  "implied_airwatch_eula", default: false, null: false
    t.integer  "forced_user_validity"
    t.boolean  "can_nominate",          default: false, null: false
  end

  add_index "profiles", ["deleted_at"], name: "index_profiles_on_deleted_at", using: :btree

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

  add_index "registration_codes", ["deleted_at"], name: "index_registration_codes_on_deleted_at", using: :btree

  create_table "salesforce_instances", force: :cascade do |t|
    t.string   "display_name"
    t.string   "group_name"
    t.string   "group_region"
    t.string   "username"
    t.string   "password"
    t.string   "security_token"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "time_zone"
    t.string   "common_locale"
    t.string   "language_locale"
    t.string   "email_encoding"
    t.string   "profile_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.datetime "deleted_at"
    t.string   "host"
    t.boolean  "in_maintainance", default: false, null: false
  end

  create_table "user_authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "ip"
    t.boolean  "successful"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_authentications", ["created_at"], name: "index_user_authentications_on_created_at", using: :btree

  create_table "user_integrations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "integration_id"
    t.string   "username",                                     null: false
    t.date     "directory_expiration_date",                    null: false
    t.integer  "directory_status",                default: 0,  null: false
    t.integer  "horizon_air_status",              default: 0,  null: false
    t.integer  "horizon_rds_status",              default: 0,  null: false
    t.integer  "horizon_view_status",             default: 0,  null: false
    t.integer  "airwatch_status",                 default: 0,  null: false
    t.integer  "office365_status",                default: 0,  null: false
    t.integer  "google_apps_status",              default: 0,  null: false
    t.integer  "airwatch_user_id"
    t.integer  "airwatch_admin_user_id"
    t.integer  "airwatch_group_id"
    t.datetime "deleted_at"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "blue_jeans_status",               default: 0,  null: false
    t.integer  "blue_jeans_user_id"
    t.integer  "salesforce_status",               default: 0,  null: false
    t.string   "salesforce_user_id"
    t.datetime "blue_jeans_removal_requested_at"
    t.string   "prohibited_services",             default: [], null: false, array: true
    t.integer  "box_status",                      default: 0,  null: false
    t.integer  "box_user_id"
    t.integer  "airwatch_sandbox_admin_group_id"
  end

  add_index "user_integrations", ["airwatch_admin_user_id"], name: "index_user_integrations_on_airwatch_admin_user_id", using: :btree
  add_index "user_integrations", ["airwatch_group_id"], name: "index_user_integrations_on_airwatch_group_id", using: :btree
  add_index "user_integrations", ["airwatch_user_id"], name: "index_user_integrations_on_airwatch_user_id", using: :btree
  add_index "user_integrations", ["deleted_at"], name: "index_user_integrations_on_deleted_at", using: :btree
  add_index "user_integrations", ["integration_id"], name: "index_user_integrations_on_integration_id", using: :btree
  add_index "user_integrations", ["user_id", "integration_id"], name: "index_user_integrations_on_user_id_and_integration_id", unique: true, using: :btree
  add_index "user_integrations", ["user_id"], name: "index_user_integrations_on_user_id", using: :btree

  create_table "user_requests", force: :cascade do |t|
    t.string  "ip"
    t.date    "date"
    t.integer "hour"
    t.integer "quantity"
    t.string  "country"
  end

  add_index "user_requests", ["date", "hour"], name: "index_user_requests_on_date_and_hour", using: :btree

  create_table "users", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "profile_id"
    t.integer  "registration_code_id"
    t.integer  "authentication_integration_id"
    t.string   "email",                                         null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "avatar"
    t.string   "country_code"
    t.string   "phone"
    t.integer  "role",                          default: 0,     null: false
    t.integer  "status",                        default: 0,     null: false
    t.string   "job_title"
    t.integer  "invitations_used",              default: 0,     null: false
    t.integer  "total_invitations",             default: 5,     null: false
    t.string   "home_region"
    t.date     "airwatch_eula_accept_date"
    t.datetime "last_authorized_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "verification_token"
    t.boolean  "can_edit_services",             default: false, null: false
    t.boolean  "can_see_reports",               default: false, null: false
    t.boolean  "can_see_opportunities",         default: false, null: false
    t.string   "desired_password"
    t.integer  "domain_id"
  end

  add_index "users", ["authentication_integration_id"], name: "index_users_on_authentication_integration_id", using: :btree
  add_index "users", ["company_id"], name: "index_users_on_company_id", using: :btree
  add_index "users", ["created_at"], name: "index_users_on_created_at", using: :btree
  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["profile_id"], name: "index_users_on_profile_id", using: :btree
  add_index "users", ["registration_code_id"], name: "index_users_on_registration_code_id", using: :btree

end
