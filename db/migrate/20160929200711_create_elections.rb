class CreateElections < ActiveRecord::Migration
  def self.up
    create_table :elections do |t|
      t.date :election_at
      t.integer :election_app_event_id
      t.boolean :can_enter_data, default: false
      t.boolean :parties_same_for_all_districts, default: true

      t.timestamps
    end
    add_index :elections, :can_enter_data

    Election.create_translation_table! :name => :string
    add_index :election_translations, :name

    # add election to districts precincts
    add_column :district_precincts, :election_id, :integer
    add_index :district_precincts, [:election_id, :district_id, :precinct_id], name: 'idx_elec_dist_prec'
  end
  def self.down
    drop_table :elections
    Election.drop_translation_table!

    # districts precincts
    remove_column :district_precincts, :election_id
    remove_index :district_precincts, name: 'idx_elec_dist_prec'
  end
end
