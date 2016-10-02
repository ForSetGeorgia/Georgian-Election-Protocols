class CreateNewCrowdDataTable < ActiveRecord::Migration
  def up
    rename_table :crowd_data, :crowd_data_orig

    create_table "crowd_data", :force => true do |t|
      t.integer  "election_id"
      t.integer  "district_id", limit: 2
      t.integer  "precinct_id", limit: 2
      t.integer  "user_id"
      t.integer  "possible_voters", limit: 3
      t.integer  "special_voters", limit: 3
      t.integer  "votes_by_1200", limit: 3
      t.integer  "votes_by_1700", limit: 3
      t.integer  "ballots_signed_for", limit: 3
      t.integer  "ballots_available", limit: 3
      t.integer  "invalid_ballots_submitted", limit: 3
      t.integer  "party_1", limit: 3
      t.integer  "party_2", limit: 3
      t.integer  "party_3", limit: 3
      t.integer  "party_4", limit: 3
      t.integer  "party_5", limit: 3
      t.integer  "party_6", limit: 3
      t.integer  "party_7", limit: 3
      t.integer  "party_8", limit: 3
      t.integer  "party_9", limit: 3
      t.integer  "party_10", limit: 3
      t.integer  "party_11", limit: 3
      t.integer  "party_12", limit: 3
      t.integer  "party_13", limit: 3
      t.integer  "party_14", limit: 3
      t.integer  "party_15", limit: 3
      t.integer  "party_16", limit: 3
      t.integer  "party_17", limit: 3
      t.integer  "party_18", limit: 3
      t.integer  "party_19", limit: 3
      t.integer  "party_20", limit: 3
      t.integer  "party_21", limit: 3
      t.integer  "party_22", limit: 3
      t.integer  "party_23", limit: 3
      t.integer  "party_24", limit: 3
      t.integer  "party_25", limit: 3
      t.integer  "party_26", limit: 3
      t.integer  "party_27", limit: 3
      t.integer  "party_28", limit: 3
      t.integer  "party_29", limit: 3
      t.integer  "party_30", limit: 3
      t.integer  "party_31", limit: 3
      t.integer  "party_32", limit: 3
      t.integer  "party_33", limit: 3
      t.integer  "party_34", limit: 3
      t.integer  "party_35", limit: 3
      t.integer  "party_36", limit: 3
      t.integer  "party_37", limit: 3
      t.integer  "party_38", limit: 3
      t.integer  "party_39", limit: 3
      t.integer  "party_40", limit: 3
      t.integer  "party_41", limit: 3
      t.integer  "party_42", limit: 3
      t.integer  "party_43", limit: 3
      t.integer  "party_44", limit: 3
      t.integer  "party_45", limit: 3
      t.integer  "party_46", limit: 3
      t.integer  "party_47", limit: 3
      t.integer  "party_48", limit: 3
      t.integer  "party_49", limit: 3
      t.integer  "party_50", limit: 3
      t.integer  "party_51", limit: 3
      t.integer  "party_52", limit: 3
      t.integer  "party_53", limit: 3
      t.integer  "party_54", limit: 3
      t.integer  "party_55", limit: 3
      t.integer  "party_56", limit: 3
      t.integer  "party_57", limit: 3
      t.integer  "party_58", limit: 3
      t.integer  "party_59", limit: 3
      t.integer  "party_60", limit: 3
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
