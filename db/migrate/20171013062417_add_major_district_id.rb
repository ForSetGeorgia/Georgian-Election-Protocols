class AddMajorDistrictId < ActiveRecord::Migration
  def up
    add_column :crowd_queues, :major_district_id, :string, limit: 10
    add_column :crowd_data, :major_district_id, :string, limit: 10
    add_column :district_parties, :major_district_id, :string, limit: 10

    remove_index :crowd_data, :name => "idx_election_location"
    add_index "crowd_data", ["election_id", "district_id", "major_district_id", "precinct_id"], :name => "idx_election_location"

    remove_index :crowd_queues, :name => "idx_queue_ids"
    remove_index :crowd_queues, :name => "idx_election_queue_ids"
    add_index "crowd_queues", ["district_id", "major_district_id", "precinct_id"], :name => "idx_queue_ids"
    add_index "crowd_queues", ["election_id", "district_id", "major_district_id", "precinct_id"], :name => "idx_election_queue_ids"

    remove_index :district_parties, :name => "index_district_parties_elec_id_dist_id"
    add_index "district_parties", ["election_id", "district_id", "major_district_id"], :name => "index_district_parties_elec_id_dist_id"

    remove_index :district_precincts, :name => "idx_dp_location"
    remove_index :district_precincts, :name => "idx_elec_dist_prec"
    add_index "district_precincts", ["district_id", "major_district_id", "precinct_id"], :name => "idx_dp_location"
    add_index "district_precincts", ["election_id", "region", "district_id", "major_district_id", "precinct_id"], :name => "idx_elec_dist_prec"

  end

  def down
    remove_index :crowd_data, :name => "idx_election_location"
    add_index "crowd_data", ["election_id", "district_id", "precinct_id"], :name => "idx_election_location"

    remove_index :crowd_queues, :name => "idx_queue_ids"
    remove_index :crowd_queues, :name => "idx_election_queue_ids"
    add_index "crowd_queues", ["district_id", "precinct_id"], :name => "idx_queue_ids"
    add_index "crowd_queues", ["election_id", "district_id", "precinct_id"], :name => "idx_election_queue_ids"

    remove_index :district_precincts, :name => "idx_dp_location"
    remove_index :district_precincts, :name => "idx_elec_dist_prec"
    add_index "district_precincts", ["district_id", "precinct_id"], :name => "idx_dp_location"
    add_index "district_precincts", ["election_id", "region", "district_id", "precinct_id"], :name => "idx_elec_dist_prec"

    remove_index :district_parties, :name => "index_district_parties_elec_id_dist_id"
    add_index "district_parties", ["election_id", "district_id"], :name => "index_district_parties_elec_id_dist_id"

    remove_column :crowd_queues, :major_district_id
    remove_column :crowd_data, :major_district_id
    remove_column :district_parties, :major_district_id, :string, limit: 10
  end
end
