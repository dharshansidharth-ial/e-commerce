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

ActiveRecord::Schema[8.1].define(version: 2026_03_25_090000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.boolean "default", default: false
    t.string "line1"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "catalog_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "catalog_products", force: :cascade do |t|
    t.boolean "active"
    t.bigint "catalog_category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "name"
    t.decimal "price"
    t.bigint "seller_id"
    t.integer "stock"
    t.datetime "updated_at", null: false
    t.index ["catalog_category_id"], name: "index_catalog_products_on_catalog_category_id"
    t.index ["seller_id"], name: "index_catalog_products_on_seller_id"
  end

  create_table "checkout_order_items", force: :cascade do |t|
    t.bigint "catalog_product_id", null: false
    t.bigint "checkout_order_id", null: false
    t.datetime "created_at", null: false
    t.decimal "price"
    t.integer "quantity"
    t.datetime "updated_at", null: false
    t.index ["catalog_product_id"], name: "index_checkout_order_items_on_catalog_product_id"
    t.index ["checkout_order_id", "catalog_product_id"], name: "idx_on_checkout_order_id_catalog_product_id_5fae6f9d9b", unique: true
    t.index ["checkout_order_id"], name: "index_checkout_order_items_on_checkout_order_id"
  end

  create_table "checkout_orders", force: :cascade do |t|
    t.bigint "address_id"
    t.datetime "created_at", null: false
    t.bigint "phone_number_id"
    t.integer "status", default: 0, null: false
    t.decimal "total_amount", default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["address_id"], name: "index_checkout_orders_on_address_id"
    t.index ["phone_number_id"], name: "index_checkout_orders_on_phone_number_id"
    t.index ["user_id"], name: "index_checkout_orders_on_user_id"
  end

  create_table "checkout_payments", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "checkout_order_id", null: false
    t.datetime "created_at", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["checkout_order_id"], name: "index_checkout_payments_on_checkout_order_id"
  end

  create_table "feedback_reviews", force: :cascade do |t|
    t.bigint "catalog_product_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "rating"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["catalog_product_id"], name: "index_feedback_reviews_on_catalog_product_id"
    t.index ["user_id"], name: "index_feedback_reviews_on_user_id"
  end

  create_table "phone_numbers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "phone_number"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "verified", default: false, null: false
    t.index ["user_id"], name: "index_phone_numbers_on_user_id"
  end

  create_table "refunds", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "checkout_payment_id", null: false
    t.datetime "created_at", null: false
    t.string "reason"
    t.datetime "updated_at", null: false
    t.index ["checkout_payment_id"], name: "index_refunds_on_checkout_payment_id"
  end

  create_table "shopping_cart_items", force: :cascade do |t|
    t.bigint "catalog_product_id", null: false
    t.datetime "created_at", null: false
    t.decimal "price"
    t.integer "quantity"
    t.bigint "shopping_cart_id", null: false
    t.datetime "updated_at", null: false
    t.index ["catalog_product_id"], name: "index_shopping_cart_items_on_catalog_product_id"
    t.index ["shopping_cart_id", "catalog_product_id"], name: "idx_on_shopping_cart_id_catalog_product_id_4067ee32aa", unique: true
    t.index ["shopping_cart_id"], name: "index_shopping_cart_items_on_shopping_cart_id"
  end

  create_table "shopping_carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "status", default: "active", null: false
    t.decimal "total", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_shopping_carts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "role"
    t.integer "seller_status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "unique_active_users_email", unique: true, where: "(deleted_at IS NULL)"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "addresses", "users"
  add_foreign_key "catalog_products", "catalog_categories"
  add_foreign_key "catalog_products", "catalog_categories"
  add_foreign_key "catalog_products", "users", column: "seller_id"
  add_foreign_key "checkout_order_items", "catalog_products"
  add_foreign_key "checkout_order_items", "catalog_products"
  add_foreign_key "checkout_order_items", "checkout_orders"
  add_foreign_key "checkout_order_items", "checkout_orders"
  add_foreign_key "checkout_orders", "addresses", on_delete: :nullify
  add_foreign_key "checkout_orders", "phone_numbers", on_delete: :nullify
  add_foreign_key "checkout_orders", "users", on_delete: :nullify
  add_foreign_key "checkout_payments", "checkout_orders"
  add_foreign_key "feedback_reviews", "catalog_products"
  add_foreign_key "feedback_reviews", "catalog_products"
  add_foreign_key "feedback_reviews", "users"
  add_foreign_key "phone_numbers", "users"
  add_foreign_key "refunds", "checkout_payments"
  add_foreign_key "shopping_cart_items", "catalog_products"
  add_foreign_key "shopping_cart_items", "catalog_products"
  add_foreign_key "shopping_cart_items", "shopping_carts"
  add_foreign_key "shopping_carts", "users"
end
