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

ActiveRecord::Schema.define(version: 2021_05_23_090609) do

  create_table "merchants", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "email"
    t.string "status"
    t.integer "role_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["role_id"], name: "index_merchants_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.string "type"
    t.string "uuid"
    t.decimal "amount", precision: 10, scale: 2
    t.string "status"
    t.string "customer_email"
    t.string "customer_phone"
    t.string "notification_url"
    t.integer "merchant_id"
    t.integer "parent_transaction_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["merchant_id"], name: "index_transactions_on_merchant_id"
    t.index ["parent_transaction_id"], name: "index_transactions_on_parent_transaction_id"
  end

end