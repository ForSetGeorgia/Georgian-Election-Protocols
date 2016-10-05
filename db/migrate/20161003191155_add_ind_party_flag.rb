class AddIndPartyFlag < ActiveRecord::Migration
  def change
    add_column :parties, :is_independent, :boolean, default: false
    add_index :parties, :is_independent
  end
end
