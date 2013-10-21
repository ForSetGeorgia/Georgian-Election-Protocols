class CreateCrowdData < ActiveRecord::Migration
  def change
    create_table :crowd_data do |t|
      t.integer :district_id
      t.integer :precinct_id
      t.integer :user_id
      t.integer :possible_voters
      t.integer :special_voters
      t.integer :votes_by_1200
      t.integer :votes_by_1700
      t.integer :ballots_signed_for
      t.integer :ballots_available
      t.integer :invalid_ballots_submitted
      t.integer :party_1
      t.integer :party_2
      t.integer :party_3
      t.integer :party_4
      t.integer :party_5
      t.integer :party_6
      t.integer :party_7
      t.integer :party_8
      t.integer :party_9
      t.integer :party_10
      t.integer :party_11
      t.integer :party_12
      t.integer :party_13
      t.integer :party_14
      t.integer :party_15
      t.integer :party_16
      t.integer :party_17
      t.integer :party_18
      t.integer :party_19
      t.integer :party_20
      t.integer :party_21
      t.integer :party_22
      t.integer :party_41

      t.timestamps
    end

    add_index :crowd_data, [:district_id, :precinct_id], :name => 'idx_location'
    add_index :crowd_data, :user_id
  end
end
