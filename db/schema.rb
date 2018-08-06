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

ActiveRecord::Schema.define(version: 20180806145039) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  create_table "internal_orders", force: :cascade do |t|
    t.datetime "date_delivered"
    t.datetime "date_received"
    t.text "observation"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "responsable_id"
    t.bigint "sector_id"
    t.index ["responsable_id"], name: "index_internal_orders_on_responsable_id"
    t.index ["sector_id"], name: "index_internal_orders_on_sector_id"
  end

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
    t.integer "initial_quantity"
    t.datetime "expiry_date"
    t.datetime "date_received"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "medication_brand_id"
    t.bigint "vademecum_id"
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
    t.string "first_name", limit: 100
    t.string "last_name", limit: 100
    t.integer "dni"
    t.integer "sex", default: 1
    t.datetime "birthdate"
    t.boolean "is_chronic"
    t.boolean "is_urban"
    t.string "phone", limit: 20
    t.string "cell_phone", limit: 20
    t.string "email", limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "patient_type_id"
    t.index ["patient_type_id"], name: "index_patients_on_patient_type_id"
  end

  create_table "prescription_statuses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "prescriptions", force: :cascade do |t|
    t.text "observation"
    t.datetime "date_received"
    t.datetime "date_dispensed"
    t.integer "prescription_status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "professional_id"
    t.bigint "patient_id"
    t.integer "status", default: 0
    t.datetime "prescribed_date"
    t.datetime "expiry_date"
    t.index ["patient_id"], name: "index_prescriptions_on_patient_id"
    t.index ["professional_id"], name: "index_prescriptions_on_professional_id"
  end

  create_table "professional_types", force: :cascade do |t|
    t.string "name", limit: 50
  end

  create_table "professionals", force: :cascade do |t|
    t.string "first_name", limit: 50
    t.string "last_name", limit: 50
    t.string "fullname", limit: 102
    t.integer "dni"
    t.string "enrollment", limit: 20
    t.string "email"
    t.string "phone"
    t.integer "sex", default: 1
    t.boolean "is_active"
    t.string "docket", limit: 10
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "professional_type_id"
    t.bigint "sector_id"
    t.index ["professional_type_id"], name: "index_professionals_on_professional_type_id"
    t.index ["sector_id"], name: "index_professionals_on_sector_id"
    t.index ["user_id"], name: "index_professionals_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.integer "dni"
    t.string "enrollment"
    t.string "address"
    t.string "email"
    t.integer "sex", default: 0
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "cuit"
    t.string "domicile"
    t.string "phone"
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quantity_medications", force: :cascade do |t|
    t.integer "medication_id"
    t.string "quantifiable_type"
    t.bigint "quantifiable_id"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quantifiable_type", "quantifiable_id"], name: "quant_med_poly"
  end

  create_table "quantity_supplies", force: :cascade do |t|
    t.integer "supply_id"
    t.string "quantifiable_type"
    t.bigint "quantifiable_id"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quantifiable_type", "quantifiable_id"], name: "quant_sup_poly"
  end

  create_table "quantity_supply_lots", force: :cascade do |t|
    t.integer "supply_lot_id"
    t.string "quantifiable_type"
    t.bigint "quantifiable_id"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quantifiable_type", "quantifiable_id"], name: "quant_sup_lot_poly"
  end

  create_table "quantity_supply_requests", force: :cascade do |t|
    t.integer "supply_id"
    t.string "quantifiable_type"
    t.bigint "quantifiable_id"
    t.integer "quantity"
    t.integer "daily_dose"
    t.integer "treatment_duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quantifiable_type", "quantifiable_id"], name: "quant_sup_req_poly"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_sectors_on_user_id"
  end

  create_table "supplies", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "observation"
    t.string "unity", limit: 100
    t.boolean "needs_expiration"
    t.integer "period_alarm"
    t.integer "expiration_alarm"
    t.integer "quantity_alarm"
    t.integer "period_control"
    t.boolean "is_active"
    t.datetime "created_at"
    t.datetime "updated_at", null: false
    t.bigint "supply_area_id"
    t.boolean "active_alarm"
    t.index ["supply_area_id"], name: "index_supplies_on_supply_area_id"
  end

  create_table "supply_areas", force: :cascade do |t|
    t.string "name", limit: 50
  end

  create_table "supply_lots", force: :cascade do |t|
    t.string "code"
    t.string "supply_name"
    t.datetime "expiry_date"
    t.datetime "date_received"
    t.integer "quantity"
    t.integer "initial_quantity"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "supply_id"
    t.datetime "deleted_at"
    t.bigint "sector_id"
    t.string "lot_code", limit: 20
    t.index ["deleted_at"], name: "index_supply_lots_on_deleted_at"
    t.index ["lot_code"], name: "index_supply_lots_on_lot_code", unique: true
    t.index ["sector_id"], name: "index_supply_lots_on_sector_id"
    t.index ["supply_id"], name: "index_supply_lots_on_supply_id"
  end

  create_table "unities", force: :cascade do |t|
    t.string "name", limit: 100
    t.integer "simela_group"
    t.decimal "simela_relation", precision: 10, scale: 4
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
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
    t.bigint "sector_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["sector_id"], name: "index_users_on_sector_id"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "vademecums", force: :cascade do |t|
    t.integer "code_number"
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

  add_foreign_key "internal_orders", "sectors"
  add_foreign_key "medications", "medication_brands"
  add_foreign_key "patients", "patient_types"
  add_foreign_key "prescriptions", "patients"
  add_foreign_key "prescriptions", "professionals"
  add_foreign_key "professionals", "professional_types"
  add_foreign_key "professionals", "sectors"
  add_foreign_key "sectors", "users"
  add_foreign_key "supplies", "supply_areas"
  add_foreign_key "supply_lots", "sectors"
  add_foreign_key "supply_lots", "supplies"
  add_foreign_key "users", "sectors"
  add_foreign_key "vademecums", "medications"
end
