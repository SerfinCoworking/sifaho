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

ActiveRecord::Schema.define(version: 20171209180540) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "laboratories", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "medication_brands", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "laboratory_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["laboratory_id"], name: "index_medication_brands_on_laboratory_id"
  end

  create_table "medications", force: :cascade do |t|
    t.integer "quantity"
    t.datetime "expiry_date"
    t.datetime "date_received"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vademecum_id"
    t.bigint "medication_brand_id"
    t.index ["medication_brand_id"], name: "index_medications_on_medication_brand_id"
    t.index ["vademecum_id"], name: "index_medications_on_vademecum_id"
  end

  create_table "patient_types", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patients", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "dni"
    t.string "address"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "patient_type_id"
    t.index ["patient_type_id"], name: "index_patients_on_patient_type_id"
  end

  create_table "prescriptions", force: :cascade do |t|
    t.text "observation"
    t.datetime "date_received"
    t.datetime "date_processed"
    t.integer "patient_id"
    t.integer "prescription_status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "professional_id"
    t.index ["professional_id"], name: "index_prescriptions_on_professional_id"
  end

  create_table "professionals", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "dni"
    t.string "enrollment"
    t.string "address"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quantity_medications", force: :cascade do |t|
    t.integer "quantifiable_id"
    t.integer "medication_id"
    t.string "quantifiable_type"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quantity_supplies", force: :cascade do |t|
    t.integer "quantificable_id"
    t.integer "supply_id"
    t.string "quantificable_type"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "sectors", force: :cascade do |t|
    t.string "sector_name"
    t.text "description"
    t.integer "complexity_level"
    t.string "applicant"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "supplies", force: :cascade do |t|
    t.integer "quantity"
    t.datetime "expiry_date"
    t.datetime "date_received"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "vademecums", force: :cascade do |t|
    t.integer "level_complexity"
    t.boolean "indication"
    t.string "specialty_enabled"
    t.string "prescription_requirement"
    t.boolean "emergency_car"
    t.string "medication_name"
    t.text "indications"
    t.bigint "medication_id"
    t.index ["medication_id"], name: "index_vademecums_on_medication_id"
  end

  add_foreign_key "patients", "patient_types"
  add_foreign_key "prescriptions", "professionals"
  add_foreign_key "vademecums", "medications"
end
