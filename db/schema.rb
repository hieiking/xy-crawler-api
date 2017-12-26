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

ActiveRecord::Schema.define(version: 20171226093536) do

  create_table "items", id: false, force: :cascade do |t|
    t.integer "product_id"
    t.string "id", null: false
    t.string "title", null: false
    t.integer "price", null: false
    t.string "desc"
    t.string "pic_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "products_id"
    t.index ["product_id"], name: "index_items_on_product_id"
    t.index ["products_id"], name: "index_items_on_products_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.string "keywords", null: false
    t.integer "upper_p"
    t.integer "lower_p"
    t.integer "alarm_p"
    t.text "record_ids"
    t.text "except_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "filter"
  end

end
