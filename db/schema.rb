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

ActiveRecord::Schema.define(version: 2022_01_10_132219) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "postal_code"
    t.text "line"
    t.bigint "city_id"
    t.bigint "country_id"
    t.bigint "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_addresses_on_city_id"
    t.index ["country_id"], name: "index_addresses_on_country_id"
    t.index ["state_id"], name: "index_addresses_on_state_id"
  end

  create_table "app_users", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "areas", force: :cascade do |t|
    t.string "name"
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_area_id"
    t.bigint "first_area_id"
    t.index ["first_area_id"], name: "index_areas_on_first_area_id"
    t.index ["parent_area_id"], name: "index_areas_on_parent_area_id"
    t.index ["parent_id"], name: "index_areas_on_parent_id"
  end

  create_table "bed_order_movements", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "bed_order_id"
    t.bigint "sector_id"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bed_order_id"], name: "index_bed_order_movements_on_bed_order_id"
    t.index ["sector_id"], name: "index_bed_order_movements_on_sector_id"
    t.index ["user_id"], name: "index_bed_order_movements_on_user_id"
  end

  create_table "bed_orders", force: :cascade do |t|
    t.bigint "bedroom_id"
    t.bigint "patient_id"
    t.bigint "sent_by_id"
    t.bigint "created_by_id"
    t.bigint "audited_by_id"
    t.bigint "received_by_id"
    t.bigint "sent_request_by_id_id"
    t.string "observation"
    t.string "remit_code"
    t.datetime "sent_date"
    t.datetime "deleted_at"
    t.datetime "date_received"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "bed_id"
    t.bigint "establishment_id"
    t.bigint "applicant_sector_id"
    t.index ["applicant_sector_id"], name: "index_bed_orders_on_applicant_sector_id"
    t.index ["audited_by_id"], name: "index_bed_orders_on_audited_by_id"
    t.index ["bed_id"], name: "index_bed_orders_on_bed_id"
    t.index ["bedroom_id"], name: "index_bed_orders_on_bedroom_id"
    t.index ["created_by_id"], name: "index_bed_orders_on_created_by_id"
    t.index ["establishment_id"], name: "index_bed_orders_on_establishment_id"
    t.index ["patient_id"], name: "index_bed_orders_on_patient_id"
    t.index ["received_by_id"], name: "index_bed_orders_on_received_by_id"
    t.index ["sent_by_id"], name: "index_bed_orders_on_sent_by_id"
    t.index ["sent_request_by_id_id"], name: "index_bed_orders_on_sent_request_by_id_id"
  end

  create_table "bedrooms", force: :cascade do |t|
    t.string "name"
    t.bigint "location_sector_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_sector_id"], name: "index_bedrooms_on_location_sector_id"
  end

  create_table "beds", force: :cascade do |t|
    t.string "name"
    t.integer "status", default: 0
    t.bigint "bedroom_id"
    t.bigint "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bedroom_id"], name: "index_beds_on_bedroom_id"
    t.index ["service_id"], name: "index_beds_on_service_id"
  end

  create_table "chron_pres_prod_lot_stocks", force: :cascade do |t|
    t.bigint "chronic_prescription_product_id"
    t.bigint "lot_stock_id"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chronic_prescription_product_id"], name: "unique_chron_pres_prod_lot_stock_cpp"
    t.index ["lot_stock_id"], name: "index_chron_pres_prod_lot_stocks_on_lot_stock_id"
  end

  create_table "chronic_dispensations", force: :cascade do |t|
    t.bigint "chronic_prescription_id"
    t.text "observation"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "provider_sector_id"
    t.index ["chronic_prescription_id"], name: "index_chronic_dispensations_on_chronic_prescription_id"
    t.index ["provider_sector_id"], name: "index_chronic_dispensations_on_provider_sector_id"
  end

  create_table "chronic_prescription_comments", force: :cascade do |t|
    t.bigint "chronic_prescription_id"
    t.bigint "user_id"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chronic_prescription_id"], name: "unique_chron_pres_on_out_pres_comments"
    t.index ["user_id"], name: "index_chronic_prescription_comments_on_user_id"
  end

  create_table "chronic_prescription_movements", force: :cascade do |t|
    t.bigint "chronic_prescription_id"
    t.bigint "user_id"
    t.bigint "sector_id"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chronic_prescription_id"], name: "unique_chron_pres_on_out_pres_movements"
    t.index ["sector_id"], name: "index_chronic_prescription_movements_on_sector_id"
    t.index ["user_id"], name: "index_chronic_prescription_movements_on_user_id"
  end

  create_table "chronic_prescription_products", force: :cascade do |t|
    t.bigint "original_chronic_prescription_product_id"
    t.bigint "chronic_dispensation_id"
    t.bigint "product_id"
    t.integer "delivery_quantity"
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "dispensation_type_id"
    t.index ["chronic_dispensation_id"], name: "index_chronic_prescription_products_on_chronic_dispensation_id"
    t.index ["dispensation_type_id"], name: "index_chronic_prescription_products_on_dispensation_type_id"
    t.index ["original_chronic_prescription_product_id"], name: "unique_org_chronic_prescription_product_cpp"
    t.index ["product_id"], name: "index_chronic_prescription_products_on_product_id"
  end

  create_table "chronic_prescriptions", force: :cascade do |t|
    t.bigint "professional_id"
    t.bigint "patient_id"
    t.bigint "provider_sector_id"
    t.bigint "establishment_id"
    t.string "remit_code"
    t.text "diagnostic"
    t.datetime "date_prescribed"
    t.date "expiry_date"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id"], name: "index_chronic_prescriptions_on_establishment_id"
    t.index ["patient_id"], name: "index_chronic_prescriptions_on_patient_id"
    t.index ["professional_id"], name: "index_chronic_prescriptions_on_professional_id"
    t.index ["provider_sector_id"], name: "index_chronic_prescriptions_on_provider_sector_id"
  end

  create_table "cities", force: :cascade do |t|
    t.bigint "state_id"
    t.string "name"
    t.bigint "department_id"
    t.index ["department_id"], name: "index_cities_on_department_id"
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "iso2"
    t.string "iso3"
    t.string "phone_code"
  end

  create_table "cronic_dispensations", force: :cascade do |t|
    t.bigint "prescription_id"
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prescription_id"], name: "index_cronic_dispensations_on_prescription_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.bigint "state_id"
    t.bigint "sanitary_zone_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sanitary_zone_id"], name: "index_departments_on_sanitary_zone_id"
    t.index ["state_id"], name: "index_departments_on_state_id"
  end

  create_table "dispensation_types", force: :cascade do |t|
    t.bigint "chronic_dispensation_id"
    t.bigint "original_chronic_prescription_product_id"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chronic_dispensation_id"], name: "index_dispensation_types_on_chronic_dispensation_id"
    t.index ["original_chronic_prescription_product_id"], name: "unique_org_chron_pres_on_dispensation_types"
  end

  create_table "establishment_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "establishments", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "short_name"
    t.string "cuit"
    t.string "domicile"
    t.string "phone"
    t.string "email"
    t.integer "sectors_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "city_id"
    t.bigint "sanitary_zone_id"
    t.bigint "establishment_type_id"
    t.string "cuie"
    t.string "siisa", default: "0000000000000"
    t.string "latitude", default: "0"
    t.string "longitude", default: "0"
    t.index ["city_id"], name: "index_establishments_on_city_id"
    t.index ["establishment_type_id"], name: "index_establishments_on_establishment_type_id"
    t.index ["sanitary_zone_id"], name: "index_establishments_on_sanitary_zone_id"
  end

  create_table "ext_ord_prod_lot_stocks", force: :cascade do |t|
    t.bigint "order_product_id"
    t.bigint "lot_stock_id"
    t.integer "quantity"
    t.integer "reserved_quantity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lot_stock_id"], name: "index_ext_ord_prod_lot_stocks_on_lot_stock_id"
    t.index ["order_product_id"], name: "index_ext_ord_prod_lot_stocks_on_order_product_id"
  end

  create_table "external_order_comments", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "user_id"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_external_order_comments_on_order_id"
    t.index ["user_id"], name: "index_external_order_comments_on_user_id"
  end

  create_table "external_order_movements", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "external_order_id"
    t.bigint "sector_id"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_order_id"], name: "index_external_order_movements_on_external_order_id"
    t.index ["sector_id"], name: "index_external_order_movements_on_sector_id"
    t.index ["user_id"], name: "index_external_order_movements_on_user_id"
  end

  create_table "external_order_product_reports", force: :cascade do |t|
    t.bigint "created_by_id"
    t.date "since_date"
    t.date "to_date"
    t.bigint "product_id"
    t.bigint "supply_id"
    t.bigint "sector_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_external_order_product_reports_on_created_by_id"
    t.index ["product_id"], name: "index_external_order_product_reports_on_product_id"
    t.index ["sector_id"], name: "index_external_order_product_reports_on_sector_id"
    t.index ["supply_id"], name: "index_external_order_product_reports_on_supply_id"
  end

  create_table "external_order_product_templates", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "external_order_template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_order_template_id"], name: "unique_ext_ord_prod_tem_on_ext_ord_tem"
    t.index ["product_id"], name: "index_external_order_product_templates_on_product_id"
  end

  create_table "external_order_products", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "product_id"
    t.integer "request_quantity"
    t.integer "delivery_quantity", default: 0
    t.text "provider_observation"
    t.text "applicant_observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "added_by_sector_id"
    t.index ["added_by_sector_id"], name: "index_external_order_products_on_added_by_sector_id"
    t.index ["order_id", "product_id"], name: "unique_product_on_external_order_products", unique: true
    t.index ["order_id"], name: "index_external_order_products_on_order_id"
    t.index ["product_id"], name: "index_external_order_products_on_product_id"
  end

  create_table "external_order_template_supplies", force: :cascade do |t|
    t.bigint "external_order_template_id"
    t.bigint "supply_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rank", default: 0
    t.index ["external_order_template_id"], name: "o_s_template"
    t.index ["supply_id"], name: "index_external_order_template_supplies_on_supply_id"
  end

  create_table "external_order_templates", force: :cascade do |t|
    t.string "name"
    t.bigint "owner_sector_id"
    t.bigint "destination_establishment_id"
    t.bigint "destination_sector_id"
    t.bigint "created_by_id"
    t.integer "order_type", default: 0
    t.text "applicant_observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "provider_observation"
    t.index ["created_by_id"], name: "index_external_order_templates_on_created_by_id"
    t.index ["destination_establishment_id"], name: "index_external_order_templates_on_destination_establishment_id"
    t.index ["destination_sector_id"], name: "index_external_order_templates_on_destination_sector_id"
    t.index ["owner_sector_id"], name: "index_external_order_templates_on_owner_sector_id"
  end

  create_table "external_orders", force: :cascade do |t|
    t.bigint "applicant_sector_id"
    t.bigint "provider_sector_id"
    t.bigint "audited_by_id"
    t.bigint "accepted_by_id"
    t.bigint "received_by_id"
    t.bigint "created_by_id"
    t.bigint "sent_request_by_id"
    t.bigint "rejected_by_id"
    t.text "provider_observation"
    t.string "remit_code"
    t.datetime "sent_date"
    t.datetime "accepted_date"
    t.datetime "date_received"
    t.datetime "requested_date"
    t.integer "status", default: 0
    t.integer "order_type", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "applicant_observation"
    t.index ["accepted_by_id"], name: "index_external_orders_on_accepted_by_id"
    t.index ["applicant_sector_id"], name: "index_external_orders_on_applicant_sector_id"
    t.index ["audited_by_id"], name: "index_external_orders_on_audited_by_id"
    t.index ["created_by_id"], name: "index_external_orders_on_created_by_id"
    t.index ["provider_sector_id"], name: "index_external_orders_on_provider_sector_id"
    t.index ["received_by_id"], name: "index_external_orders_on_received_by_id"
    t.index ["rejected_by_id"], name: "index_external_orders_on_rejected_by_id"
    t.index ["remit_code"], name: "index_external_orders_on_remit_code", unique: true
    t.index ["sent_request_by_id"], name: "index_external_orders_on_sent_request_by_id"
  end

  create_table "in_pre_prod_lot_stocks", force: :cascade do |t|
    t.bigint "inpatient_prescription_product_id"
    t.bigint "lot_stock_id"
    t.bigint "supplied_by_sector_id"
    t.integer "available_quantity"
    t.integer "reserved_quantity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inpatient_prescription_product_id"], name: "inpatient_prescription_product"
    t.index ["lot_stock_id"], name: "index_in_pre_prod_lot_stocks_on_lot_stock_id"
    t.index ["supplied_by_sector_id"], name: "index_in_pre_prod_lot_stocks_on_supplied_by_sector_id"
  end

  create_table "inpatient_movement_types", force: :cascade do |t|
    t.string "name"
    t.string "fa_icon", default: "exchange-alt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "inpatient_movements", force: :cascade do |t|
    t.bigint "bed_id"
    t.bigint "patient_id"
    t.bigint "movement_type_id"
    t.bigint "user_id"
    t.text "observations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bed_id"], name: "index_inpatient_movements_on_bed_id"
    t.index ["movement_type_id"], name: "index_inpatient_movements_on_movement_type_id"
    t.index ["patient_id"], name: "index_inpatient_movements_on_patient_id"
    t.index ["user_id"], name: "index_inpatient_movements_on_user_id"
  end

  create_table "inpatient_prescription_movements", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "order_product_id"
    t.bigint "user_id"
    t.bigint "sector_id"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_inpatient_prescription_movements_on_order_id"
    t.index ["order_product_id"], name: "index_inpatient_prescription_movements_on_order_product_id"
    t.index ["sector_id"], name: "index_inpatient_prescription_movements_on_sector_id"
    t.index ["user_id"], name: "index_inpatient_prescription_movements_on_user_id"
  end

  create_table "inpatient_prescription_products", force: :cascade do |t|
    t.bigint "inpatient_prescription_id"
    t.bigint "parent_id"
    t.bigint "product_id"
    t.integer "dose_quantity"
    t.integer "deliver_quantity"
    t.integer "interval"
    t.integer "total_dose"
    t.integer "status"
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "prescribed_by_id"
    t.bigint "delivered_by_id"
    t.index ["delivered_by_id"], name: "index_inpatient_prescription_products_on_delivered_by_id"
    t.index ["inpatient_prescription_id", "product_id", "parent_id"], name: "unique_product_on_inpatient_prescription_products", unique: true
    t.index ["inpatient_prescription_id"], name: "index_inpatient_prescription"
    t.index ["parent_id"], name: "index_inpatient_prescription_products_on_parent_id"
    t.index ["prescribed_by_id"], name: "index_inpatient_prescription_products_on_prescribed_by_id"
    t.index ["product_id"], name: "index_inpatient_prescription_products_on_product_id"
  end

  create_table "inpatient_prescriptions", force: :cascade do |t|
    t.bigint "patient_id"
    t.bigint "prescribed_by_id"
    t.bigint "bed_id"
    t.string "remit_code"
    t.text "observation"
    t.integer "status", default: 0
    t.date "date_prescribed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bed_id"], name: "index_inpatient_prescriptions_on_bed_id"
    t.index ["patient_id"], name: "index_inpatient_prescriptions_on_patient_id"
    t.index ["prescribed_by_id"], name: "index_inpatient_prescriptions_on_prescribed_by_id"
  end

  create_table "int_ord_prod_lot_stocks", force: :cascade do |t|
    t.bigint "order_product_id"
    t.bigint "lot_stock_id"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reserved_quantity", default: 0
    t.index ["lot_stock_id"], name: "index_int_ord_prod_lot_stocks_on_lot_stock_id"
    t.index ["order_product_id"], name: "index_int_ord_prod_lot_stocks_on_order_product_id"
  end

  create_table "internal_order_comments", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "user_id"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_internal_order_comments_on_order_id"
    t.index ["user_id"], name: "index_internal_order_comments_on_user_id"
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

  create_table "internal_order_product_reports", force: :cascade do |t|
    t.bigint "created_by_id"
    t.date "since_date"
    t.date "to_date"
    t.bigint "product_id"
    t.bigint "supply_id"
    t.bigint "sector_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_internal_order_product_reports_on_created_by_id"
    t.index ["product_id"], name: "index_internal_order_product_reports_on_product_id"
    t.index ["sector_id"], name: "index_internal_order_product_reports_on_sector_id"
    t.index ["supply_id"], name: "index_internal_order_product_reports_on_supply_id"
  end

  create_table "internal_order_product_templates", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "internal_order_template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["internal_order_template_id"], name: "unique_int_ord_prod_tem_on_int_ord_tem"
    t.index ["product_id"], name: "index_internal_order_product_templates_on_product_id"
  end

  create_table "internal_order_products", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "product_id"
    t.integer "request_quantity"
    t.integer "delivery_quantity", default: 0
    t.text "provider_observation"
    t.text "applicant_observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "added_by_sector_id"
    t.index ["added_by_sector_id"], name: "index_internal_order_products_on_added_by_sector_id"
    t.index ["order_id", "product_id"], name: "unique_product_on_internal_order_products", unique: true
    t.index ["order_id"], name: "index_internal_order_products_on_order_id"
    t.index ["product_id"], name: "index_internal_order_products_on_product_id"
  end

  create_table "internal_order_template_supplies", force: :cascade do |t|
    t.bigint "internal_order_template_id"
    t.bigint "supply_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rank", default: 0
    t.index ["internal_order_template_id"], name: "i_o_template"
    t.index ["supply_id"], name: "supply_id"
  end

  create_table "internal_order_templates", force: :cascade do |t|
    t.string "name"
    t.bigint "owner_sector_id"
    t.bigint "destination_sector_id"
    t.bigint "created_by_id"
    t.integer "order_type", default: 0
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_internal_order_templates_on_created_by_id"
    t.index ["destination_sector_id"], name: "index_internal_order_templates_on_destination_sector_id"
    t.index ["owner_sector_id"], name: "index_internal_order_templates_on_owner_sector_id"
  end

  create_table "internal_orders", force: :cascade do |t|
    t.bigint "provider_sector_id"
    t.bigint "applicant_sector_id"
    t.datetime "sent_date"
    t.datetime "requested_date"
    t.datetime "date_received"
    t.text "observation"
    t.integer "provider_status", default: 0
    t.integer "applicant_status", default: 0
    t.integer "status", default: 0
    t.integer "order_type", default: 0
    t.string "remit_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_sector_id"], name: "index_internal_orders_on_applicant_sector_id"
    t.index ["provider_sector_id"], name: "index_internal_orders_on_provider_sector_id"
    t.index ["remit_code"], name: "index_internal_orders_on_remit_code"
  end

  create_table "laboratories", force: :cascade do |t|
    t.bigint "cuit"
    t.bigint "gln"
    t.string "name"
    t.index ["cuit"], name: "index_laboratories_on_cuit", unique: true
    t.index ["gln"], name: "index_laboratories_on_gln", unique: true
  end

  create_table "lot_archives", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "lot_stock_id"
    t.integer "status", default: 0
    t.integer "quantity"
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "returned_by_id"
    t.index ["lot_stock_id"], name: "index_lot_archives_on_lot_stock_id"
    t.index ["returned_by_id"], name: "index_lot_archives_on_returned_by_id"
    t.index ["user_id"], name: "index_lot_archives_on_user_id"
  end

  create_table "lot_provenances", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lots_count", default: 0
  end

  create_table "lot_stocks", force: :cascade do |t|
    t.bigint "lot_id"
    t.bigint "stock_id"
    t.integer "quantity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "archived_quantity", default: 0
    t.integer "presentation"
    t.integer "reserved_quantity", default: 0
    t.index ["lot_id"], name: "index_lot_stocks_on_lot_id"
    t.index ["stock_id"], name: "index_lot_stocks_on_stock_id"
  end

  create_table "lots", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "laboratory_id"
    t.string "code"
    t.date "expiry_date"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "provenance_id", default: 1
    t.index ["deleted_at"], name: "index_lots_on_deleted_at"
    t.index ["laboratory_id"], name: "index_lots_on_laboratory_id"
    t.index ["product_id"], name: "index_lots_on_product_id"
    t.index ["provenance_id"], name: "index_lots_on_provenance_id"
  end

  create_table "monthly_consumption_areas", force: :cascade do |t|
    t.bigint "monthly_consumption_report_id"
    t.bigint "area_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_monthly_consumption_areas_on_area_id"
    t.index ["monthly_consumption_report_id"], name: "monthly_consumption_area"
  end

  create_table "monthly_consumption_reports", force: :cascade do |t|
    t.integer "report_type", default: 0
    t.bigint "product_id"
    t.bigint "created_by_id"
    t.bigint "sector_id"
    t.datetime "since_date"
    t.datetime "to_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_monthly_consumption_reports_on_created_by_id"
    t.index ["product_id"], name: "index_monthly_consumption_reports_on_product_id"
    t.index ["sector_id"], name: "index_monthly_consumption_reports_on_sector_id"
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
    t.string "action_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "actor_sector_id"
    t.index ["actor_sector_id"], name: "index_notifications_on_actor_sector_id"
    t.index ["user_id", "notify_type"], name: "index_notifications_on_user_id_and_notify_type"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "original_chronic_prescription_products", force: :cascade do |t|
    t.bigint "chronic_prescription_id"
    t.bigint "product_id"
    t.integer "request_quantity"
    t.integer "total_request_quantity", default: 0
    t.integer "total_delivered_quantity", default: 0
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "treatment_status", default: 0
    t.bigint "finished_by_professional_id"
    t.text "finished_observation"
    t.index ["chronic_prescription_id"], name: "unique_chron_pres_on_org_cron_pres_prod"
    t.index ["finished_by_professional_id"], name: "original_product_finished_by_professional"
    t.index ["product_id"], name: "index_original_chronic_prescription_products_on_product_id"
  end

  create_table "out_pres_prod_lot_stocks", force: :cascade do |t|
    t.bigint "outpatient_prescription_product_id"
    t.bigint "lot_stock_id"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lot_stock_id"], name: "index_out_pres_prod_lot_stocks_on_lot_stock_id"
    t.index ["outpatient_prescription_product_id"], name: "unique_out_pres_prod_lot_stocks_on_out_pres_prod"
  end

  create_table "outpatient_prescription_movements", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "outpatient_prescription_id"
    t.bigint "sector_id"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["outpatient_prescription_id"], name: "unique_out_pres_on_out_pres_movements"
    t.index ["sector_id"], name: "index_outpatient_prescription_movements_on_sector_id"
    t.index ["user_id"], name: "index_outpatient_prescription_movements_on_user_id"
  end

  create_table "outpatient_prescription_products", force: :cascade do |t|
    t.bigint "outpatient_prescription_id"
    t.bigint "product_id"
    t.integer "request_quantity"
    t.integer "delivery_quantity"
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["outpatient_prescription_id"], name: "unique_out_pres_prod_on_outpatient_prescriptions"
    t.index ["product_id"], name: "index_outpatient_prescription_products_on_product_id"
  end

  create_table "outpatient_prescriptions", force: :cascade do |t|
    t.bigint "professional_id"
    t.bigint "patient_id"
    t.bigint "provider_sector_id"
    t.bigint "establishment_id"
    t.string "remit_code"
    t.text "observation"
    t.date "date_prescribed"
    t.date "expiry_date"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id"], name: "index_outpatient_prescriptions_on_establishment_id"
    t.index ["patient_id"], name: "index_outpatient_prescriptions_on_patient_id"
    t.index ["professional_id"], name: "index_outpatient_prescriptions_on_professional_id"
    t.index ["provider_sector_id"], name: "index_outpatient_prescriptions_on_provider_sector_id"
  end

  create_table "patient_phones", force: :cascade do |t|
    t.integer "phone_type", default: 1
    t.string "number"
    t.bigint "patient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_patient_phones_on_patient_id"
  end

  create_table "patient_product_reports", force: :cascade do |t|
    t.datetime "since_date"
    t.datetime "to_date"
    t.bigint "product_id"
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sector_id"
    t.index ["created_by_id"], name: "index_patient_product_reports_on_created_by_id"
    t.index ["product_id"], name: "index_patient_product_reports_on_product_id"
    t.index ["sector_id"], name: "index_patient_product_reports_on_sector_id"
  end

  create_table "patient_product_state_reports", force: :cascade do |t|
    t.datetime "since_date"
    t.datetime "to_date"
    t.bigint "product_id"
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_patient_product_state_reports_on_created_by_id"
    t.index ["product_id"], name: "index_patient_product_state_reports_on_product_id"
  end

  create_table "patient_types", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patients", force: :cascade do |t|
    t.string "andes_id"
    t.string "first_name", limit: 100
    t.string "last_name", limit: 100
    t.integer "status", default: 0
    t.string "dni"
    t.integer "sex", default: 1
    t.integer "marital_status", default: 1
    t.datetime "birthdate"
    t.string "email", limit: 50
    t.string "cuil"
    t.bigint "patient_type_id", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "address_id"
    t.bigint "bed_id"
    t.index ["address_id"], name: "index_patients_on_address_id"
    t.index ["andes_id"], name: "index_patients_on_andes_id"
    t.index ["bed_id"], name: "index_patients_on_bed_id"
    t.index ["patient_type_id"], name: "index_patients_on_patient_type_id"
  end

  create_table "permission_requests", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "status", default: 0
    t.string "establishment"
    t.string "sector"
    t.string "role"
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_permission_requests_on_user_id"
  end

  create_table "prescription_movements", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "prescription_id"
    t.bigint "sector_id"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prescription_id"], name: "index_prescription_movements_on_prescription_id"
    t.index ["sector_id"], name: "index_prescription_movements_on_sector_id"
    t.index ["user_id"], name: "index_prescription_movements_on_user_id"
  end

  create_table "prescriptions", force: :cascade do |t|
    t.string "remit_code"
    t.text "observation"
    t.datetime "date_received"
    t.datetime "date_dispensed"
    t.integer "status", default: 0
    t.integer "order_type", default: 0
    t.datetime "prescribed_date"
    t.datetime "expiry_date"
    t.integer "times_dispensation"
    t.integer "times_dispensed", default: 0
    t.datetime "audited_at"
    t.datetime "dispensed_at"
    t.bigint "provider_sector_id"
    t.bigint "professional_id"
    t.bigint "patient_id"
    t.bigint "establishment_id"
    t.bigint "created_by_id"
    t.bigint "audited_by_id"
    t.bigint "dispensed_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["audited_by_id"], name: "index_prescriptions_on_audited_by_id"
    t.index ["created_by_id"], name: "index_prescriptions_on_created_by_id"
    t.index ["deleted_at"], name: "index_prescriptions_on_deleted_at"
    t.index ["dispensed_by_id"], name: "index_prescriptions_on_dispensed_by_id"
    t.index ["establishment_id"], name: "index_prescriptions_on_establishment_id"
    t.index ["patient_id"], name: "index_prescriptions_on_patient_id"
    t.index ["professional_id"], name: "index_prescriptions_on_professional_id"
    t.index ["provider_sector_id"], name: "index_prescriptions_on_provider_sector_id"
    t.index ["remit_code"], name: "index_prescriptions_on_remit_code", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.bigint "unity_id"
    t.bigint "area_id"
    t.string "code"
    t.string "name"
    t.text "description"
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "snomed_concept_id"
    t.integer "status", default: 0
    t.index ["area_id"], name: "index_products_on_area_id"
    t.index ["code"], name: "index_products_on_code"
    t.index ["snomed_concept_id"], name: "index_products_on_snomed_concept_id"
    t.index ["unity_id"], name: "index_products_on_unity_id"
  end

  create_table "professional_types", force: :cascade do |t|
    t.string "name", limit: 50
  end

  create_table "professionals", force: :cascade do |t|
    t.string "first_name", limit: 50
    t.string "last_name", limit: 50
    t.string "fullname", limit: 102
    t.integer "dni"
    t.string "email"
    t.string "phone"
    t.integer "sex", default: 1
    t.boolean "is_active", default: true
    t.string "docket", limit: 10
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "professional_type_id", default: 5
    t.index ["professional_type_id"], name: "index_professionals_on_professional_type_id"
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
    t.integer "sex", default: 1
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "theme", default: 0
    t.integer "sidebar_status", default: 0
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "purchase_areas", force: :cascade do |t|
    t.bigint "purchase_id"
    t.bigint "area_id"
    t.index ["area_id"], name: "index_purchase_areas_on_area_id"
    t.index ["purchase_id"], name: "index_purchase_areas_on_purchase_id"
  end

  create_table "purchase_comments", force: :cascade do |t|
    t.bigint "purchase_id"
    t.bigint "user_id"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["purchase_id"], name: "index_purchase_comments_on_purchase_id"
    t.index ["user_id"], name: "index_purchase_comments_on_user_id"
  end

  create_table "purchase_movements", force: :cascade do |t|
    t.bigint "purchase_id"
    t.bigint "user_id"
    t.bigint "sector_id"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["purchase_id"], name: "index_purchase_movements_on_purchase_id"
    t.index ["sector_id"], name: "index_purchase_movements_on_sector_id"
    t.index ["user_id"], name: "index_purchase_movements_on_user_id"
  end

  create_table "purchase_prod_lot_stocks", force: :cascade do |t|
    t.bigint "purchase_product_id"
    t.bigint "lot_stock_id"
    t.bigint "laboratory_id"
    t.string "lot_code"
    t.date "expiry_date"
    t.integer "position"
    t.integer "quantity"
    t.integer "presentation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["laboratory_id"], name: "index_purchase_prod_lot_stocks_on_laboratory_id"
    t.index ["lot_stock_id"], name: "index_purchase_prod_lot_stocks_on_lot_stock_id"
    t.index ["purchase_product_id"], name: "index_purchase_prod_lot_stocks_on_purchase_product_id"
  end

  create_table "purchase_products", force: :cascade do |t|
    t.bigint "purchase_id"
    t.bigint "product_id"
    t.integer "request_quantity"
    t.text "observation"
    t.string "line"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_purchase_products_on_product_id"
    t.index ["purchase_id"], name: "index_purchase_products_on_purchase_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.bigint "applicant_sector_id"
    t.bigint "provider_sector_id"
    t.bigint "area_id"
    t.integer "code_number"
    t.string "remit_code"
    t.text "observation"
    t.integer "status"
    t.datetime "received_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_sector_id"], name: "index_purchases_on_applicant_sector_id"
    t.index ["area_id"], name: "index_purchases_on_area_id"
    t.index ["provider_sector_id"], name: "index_purchases_on_provider_sector_id"
  end

  create_table "qualifications", force: :cascade do |t|
    t.bigint "professional_id"
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["professional_id"], name: "index_qualifications_on_professional_id"
  end

  create_table "quantity_ord_supply_lots", force: :cascade do |t|
    t.string "lot_code"
    t.string "quantifiable_type"
    t.bigint "quantifiable_id"
    t.integer "requested_quantity", default: 0
    t.integer "delivered_quantity", default: 0
    t.integer "status", default: 0
    t.integer "treatment_duration"
    t.integer "daily_dose"
    t.bigint "supply_id"
    t.bigint "sector_supply_lot_id"
    t.bigint "supply_lot_id"
    t.bigint "laboratory_id"
    t.bigint "cronic_dispensation_id"
    t.text "applicant_observation"
    t.text "provider_observation"
    t.date "expiry_date"
    t.datetime "dispensed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cronic_dispensation_id"], name: "index_quantity_ord_supply_lots_on_cronic_dispensation_id"
    t.index ["laboratory_id"], name: "index_quantity_ord_supply_lots_on_laboratory_id"
    t.index ["quantifiable_type", "quantifiable_id"], name: "quant_ord_sup_lot_poly"
    t.index ["sector_supply_lot_id"], name: "index_quantity_ord_supply_lots_on_sector_supply_lot_id"
    t.index ["supply_id"], name: "index_quantity_ord_supply_lots_on_supply_id"
    t.index ["supply_lot_id"], name: "index_quantity_ord_supply_lots_on_supply_lot_id"
  end

  create_table "receipt_movements", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "receipt_id"
    t.bigint "sector_id"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receipt_id"], name: "index_receipt_movements_on_receipt_id"
    t.index ["sector_id"], name: "index_receipt_movements_on_sector_id"
    t.index ["user_id"], name: "index_receipt_movements_on_user_id"
  end

  create_table "receipt_products", force: :cascade do |t|
    t.bigint "receipt_id"
    t.bigint "lot_stock_id"
    t.bigint "product_id"
    t.bigint "laboratory_id"
    t.integer "quantity"
    t.string "lot_code"
    t.date "expiry_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "provenance_id", default: 1
    t.index ["laboratory_id"], name: "index_receipt_products_on_laboratory_id"
    t.index ["lot_stock_id"], name: "index_receipt_products_on_lot_stock_id"
    t.index ["product_id"], name: "index_receipt_products_on_product_id"
    t.index ["provenance_id"], name: "index_receipt_products_on_provenance_id"
    t.index ["receipt_id"], name: "index_receipt_products_on_receipt_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.string "code"
    t.bigint "provider_sector_id"
    t.bigint "applicant_sector_id"
    t.bigint "created_by_id"
    t.bigint "received_by_id"
    t.integer "status", default: 0
    t.text "observation"
    t.datetime "received_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_sector_id"], name: "index_receipts_on_applicant_sector_id"
    t.index ["created_by_id"], name: "index_receipts_on_created_by_id"
    t.index ["provider_sector_id"], name: "index_receipts_on_provider_sector_id"
    t.index ["received_by_id"], name: "index_receipts_on_received_by_id"
  end

  create_table "report_product_lines", force: :cascade do |t|
    t.string "reportable_type"
    t.bigint "reportable_id"
    t.bigint "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_report_product_lines_on_product_id"
    t.index ["reportable_type", "reportable_id"], name: "index_report_product_lines_on_reportable_type_and_reportable_id"
  end

  create_table "reports", force: :cascade do |t|
    t.string "name", default: "Reporte"
    t.datetime "since_date"
    t.datetime "to_date"
    t.integer "report_type", default: 0
    t.bigint "supply_id"
    t.bigint "sector_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sector_id"], name: "index_reports_on_sector_id"
    t.index ["supply_id"], name: "index_reports_on_supply_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
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

  create_table "sanitary_zones", force: :cascade do |t|
    t.string "name"
    t.bigint "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_sanitary_zones_on_state_id"
  end

  create_table "sector_supply_lots", force: :cascade do |t|
    t.integer "sector_id"
    t.integer "supply_lot_id"
    t.integer "quantity", default: 0
    t.integer "initial_quantity", default: 0
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_sector_supply_lots_on_deleted_at"
    t.index ["sector_id", "supply_lot_id"], name: "sector_supply_lot"
  end

  create_table "sectors", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "user_sectors_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "establishment_id"
    t.boolean "provide_hospitalization", default: false
    t.index ["establishment_id"], name: "index_sectors_on_establishment_id"
  end

  create_table "snomed_concepts", force: :cascade do |t|
    t.string "concept_id"
    t.string "term"
    t.text "fsn"
    t.string "semantic_tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "products_count", default: 0, null: false
    t.index ["concept_id"], name: "index_snomed_concepts_on_concept_id"
  end

  create_table "states", force: :cascade do |t|
    t.bigint "country_id"
    t.string "name"
    t.index ["country_id"], name: "index_states_on_country_id"
  end

  create_table "stock_movements", force: :cascade do |t|
    t.string "order_type"
    t.bigint "order_id"
    t.bigint "stock_id"
    t.bigint "lot_stock_id"
    t.integer "quantity", default: 0
    t.boolean "adds", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "status"
    t.index ["lot_stock_id"], name: "index_stock_movements_on_lot_stock_id"
    t.index ["order_type", "order_id"], name: "order_polymorphic"
    t.index ["stock_id"], name: "index_stock_movements_on_stock_id"
  end

  create_table "stock_quantity_reports", force: :cascade do |t|
    t.bigint "created_by_id"
    t.bigint "sector_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_stock_quantity_reports_on_created_by_id"
    t.index ["sector_id"], name: "index_stock_quantity_reports_on_sector_id"
  end

  create_table "stock_report_areas", force: :cascade do |t|
    t.bigint "stock_quantity_report_id"
    t.bigint "area_id"
    t.bigint "supply_area_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_stock_report_areas_on_area_id"
    t.index ["stock_quantity_report_id"], name: "index_stock_report_areas_on_stock_quantity_report_id"
    t.index ["supply_area_id"], name: "index_stock_report_areas_on_supply_area_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.bigint "sector_id"
    t.bigint "product_id"
    t.integer "quantity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_quantity", default: 0
    t.integer "reserved_quantity", default: 0
    t.index ["product_id"], name: "index_stocks_on_product_id"
    t.index ["sector_id"], name: "index_stocks_on_sector_id"
  end

  create_table "supplies", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "observation"
    t.string "unity"
    t.boolean "needs_expiration"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "supply_area_id", default: 38
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
    t.date "expiry_date"
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
    t.index ["supply_id", "lot_code", "laboratory_id"], name: "supply_lot_laboratory_index"
    t.index ["supply_id"], name: "index_supply_lots_on_supply_id"
  end

  create_table "unify_products", force: :cascade do |t|
    t.bigint "origin_product_id"
    t.bigint "target_product_id"
    t.integer "status", default: 0
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["origin_product_id"], name: "index_unify_products_on_origin_product_id"
    t.index ["target_product_id"], name: "index_unify_products_on_target_product_id"
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
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sector_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "cities"
  add_foreign_key "cities", "states"
  add_foreign_key "external_order_products", "sectors", column: "added_by_sector_id"
  add_foreign_key "internal_order_products", "sectors", column: "added_by_sector_id"
  add_foreign_key "lots", "laboratories"
  add_foreign_key "lots", "products"
  add_foreign_key "patient_phones", "patients"
  add_foreign_key "patients", "addresses"
  add_foreign_key "permission_requests", "users"
  add_foreign_key "products", "snomed_concepts"
  add_foreign_key "report_product_lines", "products"
  add_foreign_key "reports", "sectors"
  add_foreign_key "reports", "supplies"
  add_foreign_key "reports", "users"
  add_foreign_key "sectors", "establishments"
  add_foreign_key "states", "countries"
  add_foreign_key "supply_lots", "laboratories"
  add_foreign_key "supply_lots", "supplies"
  add_foreign_key "unify_products", "products", column: "origin_product_id"
  add_foreign_key "unify_products", "products", column: "target_product_id"
  add_foreign_key "users", "sectors"
end
