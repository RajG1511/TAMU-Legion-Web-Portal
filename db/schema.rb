# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

<<<<<<< HEAD
ActiveRecord::Schema[8.0].define(version: 2025_09_29_030824) do
=======
ActiveRecord::Schema[8.0].define(version: 2025_09_26_151236) do
>>>>>>> origin/test-david
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "committee_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "committee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["committee_id"], name: "index_committee_memberships_on_committee_id"
    t.index ["user_id"], name: "index_committee_memberships_on_user_id"
  end

  create_table "committee_versions", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "committee_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "change_type"
    t.index ["committee_id"], name: "index_committee_versions_on_committee_id"
    t.index ["user_id"], name: "index_committee_versions_on_user_id"
  end

  create_table "committees", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_versions", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string "location"
    t.bigint "event_id", null: false
    t.bigint "user_id", null: false
    t.integer "visibility"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "published"
    t.string "location_type"
    t.string "campus_code"
    t.integer "campus_number"
    t.text "location_name"
    t.text "address"
    t.string "image"
    t.string "change_type"
    t.string "location_text"
    t.index ["event_id"], name: "index_event_versions_on_event_id"
    t.index ["user_id"], name: "index_event_versions_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string "location"
    t.bigint "event_category_id", null: false
    t.integer "visibility"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "published", default: 0, null: false
    t.string "location_type"
    t.string "campus_code"
    t.integer "campus_number"
    t.text "location_name"
    t.text "address"
    t.string "image"
    t.string "location_text"
    t.index ["event_category_id"], name: "index_events_on_event_category_id"
    t.index ["published"], name: "index_events_on_published"
  end

  create_table "resource_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "resource_versions", force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.integer "visibility"
    t.bigint "resource_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "change_type"
    t.boolean "published", default: false, null: false
    t.index ["resource_id"], name: "index_resource_versions_on_resource_id"
    t.index ["user_id"], name: "index_resource_versions_on_user_id"
  end

  create_table "resources", force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.integer "visibility"
    t.bigint "resource_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published", default: false, null: false
    t.index ["resource_category_id"], name: "index_resources_on_resource_category_id"
  end

  create_table "services", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "hours"
    t.string "name"
    t.text "description"
    t.date "date_performed"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_services_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.integer "graduation_year"
    t.string "major"
    t.string "t_shirt_size"
    t.integer "status"
    t.string "position"
    t.integer "role"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
<<<<<<< HEAD
    t.string "provider"
    t.string "uid"
    t.index ["uid"], name: "index_users_on_uid"
=======
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
>>>>>>> origin/test-david
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "committee_memberships", "committees"
  add_foreign_key "committee_memberships", "users"
  add_foreign_key "committee_versions", "committees"
  add_foreign_key "committee_versions", "users"
  add_foreign_key "event_versions", "users"
  add_foreign_key "events", "event_categories"
  add_foreign_key "resource_versions", "users"
  add_foreign_key "resources", "resource_categories"
  add_foreign_key "services", "users"
end
