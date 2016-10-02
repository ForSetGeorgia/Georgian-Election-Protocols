class AddElectionId < ActiveRecord::Migration
  def change
    add_column :crowd_queues, :election_id, :integer
    add_index "crowd_queues", ["election_id", "district_id", "precinct_id"], :name => "idx_election_queue_ids"

    add_column :election_data_migrations, :election_id, :integer
    add_index :election_data_migrations, :election_id

    add_column :has_protocols, :election_id, :integer
    add_index "has_protocols", ["election_id", "district_id", "precinct_id"], :name => "idx_election_hp_ids"
  end
end
