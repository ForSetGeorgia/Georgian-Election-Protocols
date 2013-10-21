class CreateDistrictPrecincts < ActiveRecord::Migration
  def change
    create_table :district_precincts do |t|
      t.integer :district_id
      t.integer :precinct_id
      t.boolean :has_protocol
      t.boolean :is_validated

      t.timestamps
    end
    
    add_index :district_precincts, [:district_id, :precinct_id], :name => :idx_dp_location
    add_index :district_precincts, :has_protocol
    add_index :district_precincts, :is_validated
  end
end
