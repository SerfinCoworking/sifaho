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

ActiveRecord::Schema.define(version: 20181213145106) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "establishments", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "cuit"
    t.string "domicile"
    t.string "phone"
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "internal_order_movements", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "internal_order_id"
    t.bigint "sector_id"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["internal_order_id"], name: "index_internal_order_movements_on_internal_order_id"
    t.index ["sector_id"], name: "index_internal_order_movements_on_sector_id"
    t.index ["user_id"], name: "index_internal_order_movements_on_user_id"
  end

  create_table "internal_orders", force: :cascade do |t|
    t.datetime "date_delivered"
    t.datetime "date_received"
    t.text "observation"
    t.integer "provider_status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "provider_sector_id"
    t.bigint "applicant_sector_id"
    t.datetime "requested_date"
    t.datetime "sent_date"
    t.integer "applicant_status", default: 0
    t.bigint "audited_by_id"
    t.bigint "sent_by_id"
    t.bigint "received_by_id"
    t.bigint "created_by_id"
    t.string "remit_code"
    t.integer "order_type", default: 0
    t.integer "status", default: 0
    t.bigint "sent_request_by_id"
    t.index ["applicant_sector_id"], name: "index_internal_orders_on_applicant_sector_id"
    t.index ["audited_by_id"], name: "index_internal_orders_on_audited_by_id"
    t.index ["created_by_id"], name: "index_internal_orders_on_created_by_id"
    t.index ["deleted_at"], name: "index_internal_orders_on_deleted_at"
    t.index ["provider_sector_id"], name: "index_internal_orders_on_provider_sector_id"
    t.index ["received_by_id"], name: "index_internal_orders_on_received_by_id"
    t.index ["remit_code"], name: "index_internal_orders_on_remit_code", unique: true
    t.index ["sent_by_id"], name: "index_internal_orders_on_sent_by_id"
    t.index ["sent_request_by_id"], name: "index_internal_orders_on_sent_request_by_id"
  end

  create_table "laboratories", force: :cascade do |t|
    t.bigint "cuit"
    t.bigint "gln"
    t.string "name"
    t.index ["cuit"], name: "index_laboratories_on_cuit", unique: true
    t.index ["gln"], name: "index_laboratories_on_gln", unique: true
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

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "actor_id"
    t.string "notify_type", null: false
    t.string "target_type"
    t.integer "target_id"
    t.string "second_target_type"
    t.integer "second_target_id"
    t.string "third_target_type"
    t.integer "third_target_id"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "action_type"
    t.index ["user_id", "notify_type"], name: "index_notifications_on_user_id_and_notify_type"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "office_supplies", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "quantity"
    t.integer "status", default: 0
    t.bigint "sector_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remit_code"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_office_supplies_on_deleted_at"
    t.index ["remit_code"], name: "index_office_supplies_on_remit_code", unique: true
    t.index ["sector_id"], name: "index_office_supplies_on_sector_id"
  end

  create_table "office_supply_categorizations", force: :cascade do |t|
    t.bigint "office_supply_id"
    t.bigint "category_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_office_supply_categorizations_on_category_id"
    t.index ["office_supply_id"], name: "index_office_supply_categorizations_on_office_supply_id"
  end

  create_table "ordering_supplies", force: :cascade do |t|
    t.text "observation"
    t.datetime "date_received"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "applicant_sector_id"
    t.bigint "provider_sector_id"
    t.datetime "requested_date"
    t.datetime "sent_date"
    t.integer "status", default: 0
    t.bigint "audited_by_id"
    t.bigint "accepted_by_id"
    t.bigint "sent_by_id"
    t.bigint "received_by_id"
    t.datetime "accepted_date"
    t.integer "order_type", default: 0
    t.bigint "created_by_id"
    t.string "remit_code"
    t.bigint "sent_request_by_id"
    t.index ["accepted_by_id"], name: "index_ordering_supplies_on_accepted_by_id"
    t.index ["applicant_sector_id"], name: "index_ordering_supplies_on_applicant_sector_id"
    t.index ["audited_by_id"], name: "index_ordering_supplies_on_audited_by_id"
    t.index ["created_by_id"], name: "index_ordering_supplies_on_created_by_id"
    t.index ["deleted_at"], name: "index_ordering_supplies_on_deleted_at"
    t.index ["provider_sector_id"], name: "index_ordering_supplies_on_provider_sector_id"
    t.index ["received_by_id"], name: "index_ordering_supplies_on_received_by_id"
    t.index ["remit_code"], name: "index_ordering_supplies_on_remit_code", unique: true
    t.index ["sent_by_id"], name: "index_ordering_supplies_on_sent_by_id"
    t.index ["sent_request_by_id"], name: "index_ordering_supplies_on_sent_request_by_id"
  end

  create_table "ordering_supply_movements", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "ordering_supply_id"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sector_id"
    t.index ["ordering_supply_id"], name: "index_ordering_supply_movements_on_ordering_supply_id"
    t.index ["sector_id"], name: "index_ordering_supply_movements_on_sector_id"
    t.index ["user_id"], name: "index_ordering_supply_movements_on_user_id"
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
    t.datetime "deleted_at"
    t.string "remit_code"
    t.bigint "created_by_id"
    t.bigint "audited_by_id"
    t.bigint "dispensed_by_id"
    t.datetime "audited_at"
    t.datetime "dispensed_at"
    t.integer "order_type", default: 0
    t.index ["audited_by_id"], name: "index_prescriptions_on_audited_by_id"
    t.index ["created_by_id"], name: "index_prescriptions_on_created_by_id"
    t.index ["deleted_at"], name: "index_prescriptions_on_deleted_at"
    t.index ["dispensed_by_id"], name: "index_prescriptions_on_dispensed_by_id"
    t.index ["patient_id"], name: "index_prescriptions_on_patient_id"
    t.index ["professional_id"], name: "index_prescriptions_on_professional_id"
    t.index ["remit_code"], name: "index_prescriptions_on_remit_code", unique: true
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

  create_table "quantity_medications", force: :cascade do |t|
    t.integer "medication_id"
    t.string "quantifiable_type"
    t.bigint "quantifiable_id"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quantifiable_type", "quantifiable_id"], name: "quant_med_poly"
  end

  create_table "quantity_ord_supply_lots", force: :cascade do |t|
    t.integer "supply_lot"
    t.string "quantifiable_type"
    t.bigint "quantifiable_id"
    t.integer "requested_quantity"
    t.integer "delivered_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sector_supply_lot_id"
    t.bigint "supply_id"
    t.bigint "supply_lot_id"
    t.datetime "expiry_date"
    t.string "lot_code"
    t.bigint "laboratory_id"
    t.integer "status", default: 0
    t.text "applicant_observation"
    t.text "provider_observation"
    t.integer "treatment_duration"
    t.integer "daily_dose"
    t.index ["laboratory_id"], name: "index_quantity_ord_supply_lots_on_laboratory_id"
    t.index ["quantifiable_type", "quantifiable_id"], name: "quant_ord_sup_lot_poly"
    t.index ["sector_supply_lot_id"], name: "index_quantity_ord_supply_lots_on_sector_supply_lot_id"
    t.index ["supply_id"], name: "index_quantity_ord_supply_lots_on_supply_id"
    t.index ["supply_lot_id"], name: "index_quantity_ord_supply_lots_on_supply_lot_id"
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

  create_table "sector_supply_lots", force: :cascade do |t|
    t.integer "sector_id"
    t.integer "supply_lot_id"
    t.integer "status", default: 0
    t.integer "quantity"
    t.integer "initial_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_sector_supply_lots_on_deleted_at"
    t.index ["sector_id", "supply_lot_id"], name: "sector_supply_lot"
  end

  create_table "sectors", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "complexity_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "establishment_id"
    t.index ["establishment_id"], name: "index_sectors_on_establishment_id"
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
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_supplies_on_deleted_at"
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
    t.string "lot_code", limit: 20
    t.bigint "laboratory_id"
    t.index ["deleted_at"], name: "index_supply_lots_on_deleted_at"
    t.index ["laboratory_id"], name: "index_supply_lots_on_laboratory_id"
    t.index ["supply_id", "lot_code", "laboratory_id"], name: "index_supply_lots_on_supply_id_and_lot_code_and_laboratory_id", unique: true
    t.index ["supply_id"], name: "index_supply_lots_on_supply_id"
  end

  create_table "unities", force: :cascade do |t|
    t.string "name", limit: 100
    t.integer "simela_group"
    t.decimal "simela_relation", precision: 10, scale: 4
  end

  create_table "user_sectors", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "sector_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sector_id"], name: "index_user_sectors_on_sector_id"
    t.index ["user_id"], name: "index_user_sectors_on_user_id"
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

  add_foreign_key "medications", "medication_brands"
  add_foreign_key "patients", "patient_types"
  add_foreign_key "prescriptions", "patients"
  add_foreign_key "prescriptions", "professionals"
  add_foreign_key "professionals", "professional_types"
  add_foreign_key "professionals", "sectors"
  add_foreign_key "quantity_ord_supply_lots", "laboratories"
  add_foreign_key "quantity_ord_supply_lots", "supplies"
  add_foreign_key "quantity_ord_supply_lots", "supply_lots"
  add_foreign_key "sectors", "establishments"
  add_foreign_key "supplies", "supply_areas"
  add_foreign_key "supply_lots", "laboratories"
  add_foreign_key "supply_lots", "supplies"
  add_foreign_key "users", "sectors"
  add_foreign_key "vademecums", "medications"
end
