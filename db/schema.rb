# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_17_010456) do

  create_table "editors", force: :cascade do |t|
    t.string "sunetid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "editors_reserves", id: false, force: :cascade do |t|
    t.integer "editor_id"
    t.integer "reserve_id"
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

end
