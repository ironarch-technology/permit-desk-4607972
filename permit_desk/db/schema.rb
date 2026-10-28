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

ActiveRecord::Schema[7.1].define(version: 2025_07_22_142000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "name", null: false
    t.string "role", default: "applicant", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_accounts_on_email", unique: true
  end

  create_table "correction_items", force: :cascade do |t|
    t.bigint "permit_application_id", null: false
    t.integer "cycle", default: 1, null: false
    t.string "code", null: false
    t.text "narrative"
    t.string "citation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permit_application_id", "cycle", "code"], name: "index_correction_items_on_application_cycle_code", unique: true
    t.index ["permit_application_id"], name: "index_correction_items_on_permit_application_id"
  end

  create_table "correction_responses", force: :cascade do |t|
    t.bigint "correction_item_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["correction_item_id"], name: "index_correction_responses_on_correction_item_id"
  end

  create_table "fee_quotes", force: :cascade do |t|
    t.bigint "permit_application_id", null: false
    t.bigint "total_cents", null: false
    t.jsonb "breakdown", default: {}, null: false
    t.string "quote_reference", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permit_application_id"], name: "index_fee_quotes_on_permit_application_id"
  end

  create_table "inspection_bookings", force: :cascade do |t|
    t.bigint "permit_application_id", null: false
    t.string "slot_id", null: false
    t.string "inspection_type", null: false
    t.datetime "scheduled_for"
    t.string "status", default: "requested", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permit_application_id"], name: "index_inspection_bookings_on_permit_application_id"
  end

  create_table "parcels", force: :cascade do |t|
    t.string "address", null: false
    t.string "district", null: false
    t.string "zoning_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_parcels_on_address", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "permit_application_id", null: false
    t.string "capture_reference", null: false
    t.bigint "amount_cents", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["capture_reference"], name: "index_payments_on_capture_reference"
    t.index ["permit_application_id"], name: "index_payments_on_permit_application_id"
  end

  create_table "permit_applications", force: :cascade do |t|
    t.string "reference", null: false
    t.bigint "account_id", null: false
    t.bigint "parcel_id"
    t.string "work_type", null: false
    t.text "scope_narrative"
    t.bigint "valuation_cents", default: 0, null: false
    t.string "applicant_name"
    t.string "applicant_email"
    t.string "applicant_phone"
    t.string "contractor_licence"
    t.date "contractor_licence_expiry"
    t.string "state", default: "draft", null: false
    t.string "submission_key"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "permit_number"
    t.datetime "issued_at"
    t.datetime "valid_until"
    t.index ["account_id"], name: "index_permit_applications_on_account_id"
    t.index ["parcel_id"], name: "index_permit_applications_on_parcel_id"
    t.index ["permit_number"], name: "index_permit_applications_on_permit_number"
    t.index ["reference"], name: "index_permit_applications_on_reference", unique: true
    t.index ["state"], name: "index_permit_applications_on_state"
  end

  create_table "transitions", force: :cascade do |t|
    t.bigint "permit_application_id", null: false
    t.string "from_state"
    t.string "to_state", null: false
    t.string "actor", null: false
    t.string "source_system"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permit_application_id", "created_at"], name: "index_transitions_on_permit_application_id_and_created_at"
    t.index ["permit_application_id"], name: "index_transitions_on_permit_application_id"
  end

  create_table "zoning_checks", force: :cascade do |t|
    t.bigint "permit_application_id", null: false
    t.string "handle", null: false
    t.string "result"
    t.text "detail"
    t.datetime "settled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["handle"], name: "index_zoning_checks_on_handle"
    t.index ["permit_application_id"], name: "index_zoning_checks_on_permit_application_id"
  end

  add_foreign_key "correction_items", "permit_applications"
  add_foreign_key "correction_responses", "correction_items"
  add_foreign_key "fee_quotes", "permit_applications"
  add_foreign_key "inspection_bookings", "permit_applications"
  add_foreign_key "payments", "permit_applications"
  add_foreign_key "permit_applications", "accounts"
  add_foreign_key "permit_applications", "parcels"
  add_foreign_key "transitions", "permit_applications"
  add_foreign_key "zoning_checks", "permit_applications"
end
