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

ActiveRecord::Schema.define(version: 2022_05_26_134209) do

  create_table "job_offers", force: :cascade do |t|
    t.integer "profession_id"
    t.decimal "office_latitude", precision: 8, scale: 6
    t.decimal "office_longitude", precision: 9, scale: 6
    t.string "continent"
    t.index ["profession_id"], name: "index_job_offers_on_profession_id"
  end

  create_table "professions", force: :cascade do |t|
    t.string "category_name", null: false
  end

  add_foreign_key "job_offers", "professions"
end
