class ChangePrecinctType < ActiveRecord::Migration
  def self.up
    # the district and precinct id were integers, however due to the changes in 2016, the id is now a string
    # so update all district/precinct fields to be a string

    remove_index "crowd_data", :name => "idx_election_location"
    remove_index "crowd_queues", :name => "idx_queue_ids"
    remove_index "crowd_queues", :name => "idx_election_queue_ids"
    remove_index "district_precincts", :name => "idx_dp_location"
    remove_index "district_precincts", :name => "idx_elec_dist_prec"
    remove_index "has_protocols", :name => "idx_hp_ids"
    remove_index "has_protocols", :name => "idx_election_hp_ids"

    change_column :crowd_data, :district_id, 'VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci'
    change_column :crowd_queues, :district_id, 'VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci'
    change_column :district_precincts, :district_id, 'VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci'
    change_column :has_protocols, :district_id, 'VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci'

    change_column :crowd_data, :precinct_id, 'VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci'
    change_column :crowd_queues, :precinct_id, 'VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci'
    change_column :district_precincts, :precinct_id, 'VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci'
    change_column :has_protocols, :precinct_id, 'VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci'

    add_index "crowd_data", ["election_id", "district_id", "precinct_id"], :name => "idx_election_location"
    add_index "crowd_queues", ["district_id", "precinct_id"], :name => "idx_queue_ids"
    add_index "crowd_queues", ["election_id", "district_id", "precinct_id"], :name => "idx_election_queue_ids"
    add_index "district_precincts", ["district_id", "precinct_id"], :name => "idx_dp_location"
    add_index "district_precincts", ["election_id", "region", "district_id", "precinct_id"], :name => "idx_elec_dist_prec"
    add_index "has_protocols", ["district_id", "precinct_id"], :name => "idx_hp_ids"
    add_index "has_protocols", ["election_id", "district_id", "precinct_id"], :name => "idx_election_hp_ids"

  end
  def self.down
    remove_index "crowd_data", :name => "idx_election_location"
    remove_index "crowd_queues", :name => "idx_queue_ids"
    remove_index "crowd_queues", :name => "idx_election_queue_ids"
    remove_index "district_precincts", :name => "idx_dp_location"
    remove_index "district_precincts", :name => "idx_elec_dist_prec"
    remove_index "has_protocols", :name => "idx_hp_ids"
    remove_index "has_protocols", :name => "idx_election_hp_ids"

    change_column :crowd_data, :district_id, :integer
    change_column :crowd_queues, :district_id, :integer
    change_column :district_precincts, :district_id, :integer
    change_column :has_protocols, :district_id, :integer

    change_column :crowd_data, :precinct_id, :integer
    change_column :crowd_queues, :precinct_id, :integer
    change_column :district_precincts, :precinct_id, :integer
    change_column :has_protocols, :precinct_id, :integer

    add_index "crowd_data", ["election_id", "district_id", "precinct_id"], :name => "idx_election_location"
    add_index "crowd_queues", ["district_id", "precinct_id"], :name => "idx_queue_ids"
    add_index "crowd_queues", ["election_id", "district_id", "precinct_id"], :name => "idx_election_queue_ids"
    add_index "district_precincts", ["district_id", "precinct_id"], :name => "idx_dp_location"
    add_index "district_precincts", ["election_id", "region", "district_id", "precinct_id"], :name => "idx_elec_dist_prec"
    add_index "has_protocols", ["district_id", "precinct_id"], :name => "idx_hp_ids"
    add_index "has_protocols", ["election_id", "district_id", "precinct_id"], :name => "idx_election_hp_ids"

  end
end
