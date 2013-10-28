class CreateCrowdQueues < ActiveRecord::Migration
  def change
    create_table :crowd_queues do |t|
      t.integer :user_id
      t.integer :district_id
      t.integer :precinct_id
      t.boolean :is_finished

      t.timestamps
    end
    
    add_index :crowd_queues, :user_id
    add_index :crowd_queues, [:district_id, :precinct_id], :name => 'idx_queue_ids'
    add_index :crowd_queues, :is_finished
  end
end
