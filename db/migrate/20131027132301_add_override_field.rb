class AddOverrideField < ActiveRecord::Migration
  def change
    add_column :president2013s, :is_overriden, :boolean, :default => false
    add_index :president2013s, :is_overriden
  end
end
