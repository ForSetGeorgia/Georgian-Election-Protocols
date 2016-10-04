class CreateElectionUsers < ActiveRecord::Migration
  def change
    create_table :election_users do |t|
      t.integer :election_id
      t.integer :user_id

      t.timestamps
    end
    add_index :election_users, :election_id
    add_index :election_users, :user_id
  end
end
