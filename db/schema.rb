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

ActiveRecord::Schema[8.0].define(version: 2025_09_07_095046) do
  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "time_zone", default: "America/Los_Angeles", null: false
    t.string "venue"
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zipcode"
    t.string "status", default: "draft", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ends_at"], name: "index_events_on_ends_at"
    t.index ["starts_at"], name: "index_events_on_starts_at"
    t.index ["status", "starts_at"], name: "index_events_on_status_and_starts_at"
    t.index ["status"], name: "index_events_on_status"
    t.index ["time_zone"], name: "index_events_on_time_zone"
    t.index ["zipcode"], name: "index_events_on_zipcode"
  end
end
