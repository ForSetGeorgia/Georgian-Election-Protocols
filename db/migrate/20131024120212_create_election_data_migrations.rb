class CreateElectionDataMigrations < ActiveRecord::Migration
  def change
    create_table :election_data_migrations do |t|
      t.integer :num_precincts
      t.string :file_name
      t.datetime :recieved_success_notification_at

      t.timestamps
    end
    
    add_index :election_data_migrations, :file_name
  end
end
