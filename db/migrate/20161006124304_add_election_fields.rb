class AddElectionFields < ActiveRecord::Migration
  def change
    add_column :elections, :max_party_in_district, :integer, default: 0
    add_column :elections, :protocol_top_box_margin, :integer, default: 0
    add_column :elections, :protocol_party_top_margin, :integer, default: 0
  end
end
