class CreateHasProtocols < ActiveRecord::Migration
  def change
    create_table :has_protocols do |t|
      t.integer :district_id
      t.integer :precinct_id

      t.timestamps
    end
    
    add_index :has_protocols, [:district_id, :precinct_id], :name => 'idx_hp_ids'

  end
end
