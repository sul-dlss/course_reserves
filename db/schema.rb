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

ActiveRecord::Schema.define(version: 2018_04_06_221446) do

  create_table "editors", force: :cascade do |t|
    t.string "sunetid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
