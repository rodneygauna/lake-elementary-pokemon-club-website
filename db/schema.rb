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

ActiveRecord::Schema[8.0].define(version: 2025_09_07_195108) do
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

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "suffix_name"
    t.string "grade"
    t.string "class_number"
    t.string "teacher_name"
    t.string "favorite_pokemon"
    t.text "notes"
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grade"], name: "index_students_on_grade"
    t.index ["last_name", "grade"], name: "index_students_on_last_name_and_grade"
    t.index ["last_name"], name: "index_students_on_last_name"
    t.index ["status", "grade"], name: "index_students_on_status_and_grade"
    t.index ["status"], name: "index_students_on_status"
  end

  create_table "user_students", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "student_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_user_students_on_student_id"
    t.index ["user_id", "student_id"], name: "index_user_students_on_user_id_and_student_id", unique: true
    t.index ["user_id"], name: "index_user_students_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone_number"
    t.string "role", default: "user", null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["status", "role"], name: "index_users_on_status_and_role"
    t.index ["status"], name: "index_users_on_status"
  end

  add_foreign_key "sessions", "users"
  add_foreign_key "user_students", "students"
  add_foreign_key "user_students", "users"
end
