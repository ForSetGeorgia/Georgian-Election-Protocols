class AddParlFlag < ActiveRecord::Migration
  def up
    add_column :elections, :is_parliamentary, :boolean, default: false

    # mark existing parliamentary elections as true
    elections_ids = [2,3,4,5]
    Election.where(id: elections_ids).update_all(is_parliamentary: true)
  end

  def down
    remove_column :elections, :is_parliamentary
  end
end
