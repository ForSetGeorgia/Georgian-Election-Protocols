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

ActiveRecord::Schema.define(:version => 20161006124304) do

  create_table "crowd_data", :force => true do |t|
    t.integer  "election_id"
    t.integer  "district_id"
    t.string   "precinct_id",               :limit => 10
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
    t.integer  "party_23"
    t.integer  "party_24"
    t.integer  "party_25"
    t.integer  "party_26"
    t.integer  "party_27"
    t.integer  "party_28"
    t.integer  "party_29"
    t.integer  "party_30"
    t.integer  "party_31"
    t.integer  "party_32"
    t.integer  "party_33"
    t.integer  "party_34"
    t.integer  "party_35"
    t.integer  "party_36"
    t.integer  "party_37"
    t.integer  "party_38"
    t.integer  "party_39"
    t.integer  "party_40"
    t.integer  "party_41"
    t.integer  "party_42"
    t.integer  "party_43"
    t.integer  "party_44"
    t.integer  "party_45"
    t.integer  "party_46"
    t.integer  "party_47"
    t.integer  "party_48"
    t.integer  "party_49"
    t.integer  "party_50"
    t.integer  "party_51"
    t.integer  "party_52"
    t.integer  "party_53"
    t.integer  "party_54"
    t.integer  "party_55"
    t.integer  "party_56"
    t.integer  "party_57"
    t.integer  "party_58"
    t.integer  "party_59"
    t.integer  "party_60"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_valid"
    t.boolean  "is_extra",                                :default => false
  end

  add_index "crowd_data", ["election_id", "district_id", "precinct_id"], :name => "idx_election_location"
  add_index "crowd_data", ["is_extra"], :name => "index_crowd_data_on_is_extra"
  add_index "crowd_data", ["is_valid"], :name => "index_crowd_data_on_is_valid"
  add_index "crowd_data", ["user_id"], :name => "index_crowd_data_on_user_id"

  create_table "crowd_data_orig", :force => true do |t|
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
    t.boolean  "is_valid"
    t.boolean  "is_extra",                  :default => false
  end

  add_index "crowd_data_orig", ["district_id", "precinct_id"], :name => "idx_location"
  add_index "crowd_data_orig", ["is_extra"], :name => "index_crowd_data_on_is_extra"
  add_index "crowd_data_orig", ["is_valid"], :name => "index_crowd_data_on_is_valid"
  add_index "crowd_data_orig", ["user_id"], :name => "index_crowd_data_on_user_id"

  create_table "crowd_queues", :force => true do |t|
    t.integer  "user_id"
    t.integer  "district_id"
    t.string   "precinct_id", :limit => 10
    t.boolean  "is_finished"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "election_id"
  end

  add_index "crowd_queues", ["district_id", "precinct_id"], :name => "idx_queue_ids"
  add_index "crowd_queues", ["election_id", "district_id", "precinct_id"], :name => "idx_election_queue_ids"
  add_index "crowd_queues", ["is_finished"], :name => "index_crowd_queues_on_is_finished"
  add_index "crowd_queues", ["user_id"], :name => "index_crowd_queues_on_user_id"

  create_table "district_parties", :force => true do |t|
    t.integer  "election_id"
    t.integer  "district_id"
    t.integer  "party_number"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "district_parties", ["election_id", "district_id"], :name => "index_district_parties_on_election_id_and_district_id"

  create_table "district_precincts", :force => true do |t|
    t.integer  "district_id"
    t.string   "precinct_id",   :limit => 10
    t.boolean  "has_protocol",                :default => false
    t.boolean  "is_validated",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "has_amendment",               :default => false
    t.integer  "election_id"
    t.string   "region"
  end

  add_index "district_precincts", ["district_id", "precinct_id"], :name => "idx_dp_location"
  add_index "district_precincts", ["election_id", "region", "district_id", "precinct_id"], :name => "idx_elec_dist_prec"
  add_index "district_precincts", ["has_amendment"], :name => "index_district_precincts_on_has_amendment"
  add_index "district_precincts", ["has_protocol"], :name => "index_district_precincts_on_has_protocol"
  add_index "district_precincts", ["is_validated"], :name => "index_district_precincts_on_is_validated"

  create_table "election_data_migrations", :force => true do |t|
    t.integer  "num_precincts"
    t.string   "file_name"
    t.datetime "recieved_success_notification_at"
    t.boolean  "success"
    t.string   "notification_msg"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "election_id"
  end

  add_index "election_data_migrations", ["election_id"], :name => "index_election_data_migrations_on_election_id"
  add_index "election_data_migrations", ["file_name"], :name => "index_election_data_migrations_on_file_name"

  create_table "election_translations", :force => true do |t|
    t.integer  "election_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "election_translations", ["election_id"], :name => "index_election_translations_on_election_id"
  add_index "election_translations", ["locale"], :name => "index_election_translations_on_locale"
  add_index "election_translations", ["name"], :name => "index_election_translations_on_name"

  create_table "election_users", :force => true do |t|
    t.integer  "election_id"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "election_users", ["election_id"], :name => "index_election_users_on_election_id"
  add_index "election_users", ["user_id"], :name => "index_election_users_on_user_id"

  create_table "elections", :force => true do |t|
    t.date     "election_at"
    t.integer  "election_app_event_id"
    t.boolean  "can_enter_data",                 :default => false
    t.boolean  "parties_same_for_all_districts", :default => true
    t.boolean  "is_local_majoritarian",          :default => false
    t.boolean  "has_regions",                    :default => false
    t.boolean  "has_district_names",             :default => false
    t.string   "analysis_table_name"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.integer  "max_party_in_district",          :default => 0
    t.integer  "protocol_top_box_margin",        :default => 0
    t.integer  "protocol_party_top_margin",      :default => 0
  end

  add_index "elections", ["can_enter_data"], :name => "index_elections_on_can_enter_data"

  create_table "has_protocols", :force => true do |t|
    t.integer  "district_id"
    t.string   "precinct_id", :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "election_id"
  end

  add_index "has_protocols", ["district_id", "precinct_id"], :name => "idx_hp_ids"
  add_index "has_protocols", ["election_id", "district_id", "precinct_id"], :name => "idx_election_hp_ids"

  create_table "parties", :force => true do |t|
    t.integer  "election_id"
    t.integer  "number",         :limit => 1
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.boolean  "is_independent",              :default => false
  end

  add_index "parties", ["election_id"], :name => "index_parties_on_election_id"
  add_index "parties", ["is_independent"], :name => "index_parties_on_is_independent"

  create_table "party_translations", :force => true do |t|
    t.integer  "party_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "party_translations", ["locale"], :name => "index_party_translations_on_locale"
  add_index "party_translations", ["name"], :name => "index_party_translations_on_name"
  add_index "party_translations", ["party_id"], :name => "index_party_translations_on_party_id"

  create_table "president2013s", :force => true do |t|
    t.string   "region"
    t.integer  "district_id"
    t.string   "district_name"
    t.integer  "precinct_id"
    t.integer  "attached_precinct_id"
    t.integer  "num_possible_voters"
    t.integer  "num_special_voters"
    t.integer  "num_at_12"
    t.integer  "num_at_17"
    t.integer  "num_votes"
    t.integer  "num_ballots"
    t.integer  "num_invalid_votes"
    t.integer  "num_valid_votes"
    t.integer  "logic_check_fail"
    t.integer  "logic_check_difference"
    t.integer  "more_ballots_than_votes_flag"
    t.integer  "more_ballots_than_votes"
    t.integer  "more_votes_than_ballots_flag"
    t.integer  "more_votes_than_ballots"
    t.integer  "1 - Tamaz Bibiluri"
    t.integer  "2 - Giorgi Liluashvili"
    t.integer  "3 - Sergo Javakhidze"
    t.integer  "4 - Koba Davitashvili"
    t.integer  "5 - Davit Bakradze"
    t.integer  "6 - Akaki Asatiani"
    t.integer  "7 - Nino Chanishvili"
    t.integer  "8 - Teimuraz Bobokhidze"
    t.integer  "9 - Shalva Natelashvili"
    t.integer  "10 - Giorgi Targamadze"
    t.integer  "11 - Levan Chachua"
    t.integer  "12 - Nestan Kirtadze"
    t.integer  "13 - Giorgi Chikhladze"
    t.integer  "14 - Nino Burjanadze"
    t.integer  "15 - Zurab Kharatishvili"
    t.integer  "16 - Mikheil Saluashvili"
    t.integer  "17 - Kartlos Gharibashvili"
    t.integer  "18 - Mamuka Chokhonelidze"
    t.integer  "19 - Avtandil Margiani"
    t.integer  "20 - Nugzar Avaliani"
    t.integer  "21 - Mamuka Melikishvili"
    t.integer  "22 - Teimuraz Mzhavia"
    t.integer  "41 - Giorgi Margvelashvili"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_overriden",                 :default => false
  end

  add_index "president2013s", ["district_id"], :name => "index_president2013s_on_district_id"
  add_index "president2013s", ["is_overriden"], :name => "index_president2013s_on_is_overriden"
  add_index "president2013s", ["precinct_id"], :name => "index_president2013s_on_precinct_id"
  add_index "president2013s", ["region"], :name => "index_president2013s_on_region"

  create_table "region_district_names", :force => true do |t|
    t.string   "region"
    t.integer  "district_id"
    t.string   "district_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "region_district_names", ["district_id"], :name => "index_region_district_names_on_district_id"

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
    t.string   "trained"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
