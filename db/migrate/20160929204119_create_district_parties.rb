class CreateDistrictParties < ActiveRecord::Migration
  def change
    create_table :district_parties do |t|
      t.integer :election_id
      t.integer :district_id
      t.integer :party_number

      t.timestamps
    end
    add_index :district_parties, [:election_id, :district_id]
  end
end
