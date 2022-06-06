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

ActiveRecord::Schema.define(version: 2022_01_04_174028) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
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
    t.integer "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "editors", force: :cascade do |t|
    t.string "sunetid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "editors_reserves", id: false, force: :cascade do |t|
    t.integer "editor_id"
    t.integer "reserve_id"
    t.index ["editor_id", "reserve_id"], name: "index_editors_reserves_on_editor_id_and_reserve_id"
    t.index ["reserve_id", "editor_id"], name: "index_editors_reserves_on_reserve_id_and_editor_id"
  end

  create_table "reserves", force: :cascade do |t|
    t.string "cid"
    t.string "sid"
    t.string "desc"
    t.string "library"
    t.boolean "immediate"
    t.string "term"
    t.string "compound_key"
    t.string "cross_listings"
    t.string "contact_name"
    t.string "contact_phone"
    t.string "contact_email"
    t.text "instructor_names"
    t.text "instructor_sunet_ids"
    t.string "editor_sunet_ids"
    t.text "item_list"
    t.boolean "has_been_sent"
    t.boolean "disabled"
    t.string "sent_date"
    t.text "sent_item_list"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
