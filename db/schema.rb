# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090413135700) do

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "company_number"
    t.text     "address"
    t.string   "url"
    t.string   "wikipedia_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_image_url"
    t.string   "company_category"
    t.string   "company_status"
    t.date     "incorporation_date"
    t.string   "country_code",       :limit => 2
  end

  add_index "companies", ["company_category"], :name => "index_companies_on_company_category"
  add_index "companies", ["company_number"], :name => "index_companies_on_company_number"
  add_index "companies", ["company_status"], :name => "index_companies_on_company_status"
  add_index "companies", ["name"], :name => "index_companies_on_name"
  add_index "companies", ["url"], :name => "index_companies_on_url"

  create_table "lobbyist_clients", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lobbyist_clients", ["company_id"], :name => "index_lobbyist_clients_on_company_id"

  create_table "ogc_suppliers", :force => true do |t|
    t.string   "name"
    t.integer  "ogc_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ogc_suppliers", ["company_id"], :name => "index_ogc_suppliers_on_company_id"

  create_table "search_results", :force => true do |t|
    t.integer "search_id"
    t.integer "company_id"
  end

  add_index "search_results", ["company_id"], :name => "index_search_results_on_company_id"
  add_index "search_results", ["search_id"], :name => "index_search_results_on_search_id"

  create_table "searches", :force => true do |t|
    t.string   "term"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["term"], :name => "index_searches_on_term"

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope",          :limit => 40
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "scope", "sequence"], :name => "index_slugs_on_name_and_sluggable_type_and_scope_and_sequence", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

end
