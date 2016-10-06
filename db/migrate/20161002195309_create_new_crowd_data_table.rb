class CreateNewCrowdDataTable < ActiveRecord::Migration
  def up
    rename_table :crowd_data, :crowd_data_orig

    create_table "crowd_data", :force => true do |t|
      t.integer  "election_id"
      t.integer  "district_id"
      t.string  "precinct_id", limit: 10
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
      t.boolean  "is_extra", :default => false
    end
    add_index "crowd_data", ["election_id", "district_id", "precinct_id"], :name => "idx_election_location"
    add_index "crowd_data", ["is_extra"], :name => "index_crowd_data_on_is_extra"
    add_index "crowd_data", ["is_valid"], :name => "index_crowd_data_on_is_valid"
    add_index "crowd_data", ["user_id"], :name => "index_crowd_data_on_user_id"

    # move all data from old to new table
    client = ActiveRecord::Base.connection
    sql = "insert into crowd_data
          (
            district_id, precinct_id, user_id, possible_voters, special_voters, votes_by_1200, votes_by_1700,
            ballots_signed_for, ballots_available, invalid_ballots_submitted,
            party_1, party_2, party_3, party_4, party_5, party_6, party_7, party_8, party_9, party_10,
            party_11, party_12, party_13, party_14, party_15, party_16, party_17, party_18, party_19,
            party_20, party_21, party_22, party_41, created_at, updated_at, is_valid, is_extra
          )
          select
            district_id, precinct_id, user_id, possible_voters, special_voters, votes_by_1200, votes_by_1700,
            ballots_signed_for, ballots_available, invalid_ballots_submitted,
            party_1, party_2, party_3, party_4, party_5, party_6, party_7, party_8, party_9, party_10,
            party_11, party_12, party_13, party_14, party_15, party_16, party_17, party_18, party_19,
            party_20, party_21, party_22, party_41, created_at, updated_at, is_valid, is_extra
          from crowd_data_orig"
    client.execute(sql)

  end

  def down
    drop_table :crowd_data
    rename_table :crowd_data_orig, :crowd_data
  end
end
