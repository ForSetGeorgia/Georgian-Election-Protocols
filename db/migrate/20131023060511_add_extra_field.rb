class AddExtraField < ActiveRecord::Migration
  def change
    add_column :crowd_data, :is_extra, :boolean, :default => false
    add_index :crowd_data, :is_extra
  end
end
