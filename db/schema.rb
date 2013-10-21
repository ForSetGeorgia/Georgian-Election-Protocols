# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131021174525) do

  create_table "crowd_data", :force => true do |t|
    t.integer  "district_id"
    t.integer  "precinct_id"
    t.integer  "user_id"
    t.integer  "possible_voters"
    t.integer  "special_voters"
    t.integer  "votes_by_1200"
    t.integer  "votes_by_1700"
    t.integer  "ballots_signed_for"
    t.integer  "ballots_available"
    t.integer  "invalid_ballots_submitted"
    t.integer  "party_1"
    t.integer  "party_2"
    t.integer  "party_3"
    t.integer  "party_4"
    t.integer  "party_5"
    t.integer  "party_6"
    t.integer  "party_7"
    t.integer  "party_8"
    t.integer  "party_9"
    t.integer  "party_10"
    t.integer  "party_11"
    t.integer  "party_12"
    t.integer  "party_13"
    t.integer  "party_14"
    t.integer  "party_15"
    t.integer  "party_16"
    t.integer  "party_17"
    t.integer  "party_18"
    t.integer  "party_19"
    t.integer  "party_20"
    t.integer  "party_21"
    t.integer  "party_22"
    t.integer  "party_41"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "crowd_data", ["district_id", "precinct_id"], :name => "idx_location"
  add_index "crowd_data", ["user_id"], :name => "index_crowd_data_on_user_id"

  create_table "district_precincts", :force => true do |t|
    t.integer  "district_id"
    t.integer  "precinct_id"
    t.boolean  "has_protocol"
    t.boolean  "is_validated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "district_precincts", ["district_id", "precinct_id"], :name => "idx_dp_location"
  add_index "district_precincts", ["has_protocol"], :name => "index_district_precincts_on_has_protocol"
  add_index "district_precincts", ["is_validated"], :name => "index_district_precincts_on_is_validated"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.integer  "role",                   :default => 0,  :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
