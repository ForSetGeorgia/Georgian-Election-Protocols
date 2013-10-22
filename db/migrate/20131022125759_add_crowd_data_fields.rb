class AddCrowdDataFields < ActiveRecord::Migration
  def change
    add_column :crowd_data, :is_valid, :boolean, :default => nil
    add_index :crowd_data, :is_valid
  end
end
