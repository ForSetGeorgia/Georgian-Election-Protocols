class CreateParties < ActiveRecord::Migration
  def self.up
    create_table :parties do |t|
      t.integer :election_id
      t.integer :number, limit: 1

      t.timestamps
    end
    add_index :parties, :election_id

    Party.create_translation_table! :name => :string
    add_index :party_translations, :name
  end
  def self.down
    drop_table :parties
    Party.drop_translation_table!
  end
end
