class ChangeDataTypes < ActiveRecord::Migration
  def up
    change_column :elections, :protocol_top_box_margin, :string, limit: 10, default: '0'
    change_column :elections, :protocol_party_top_margin, :string, limit: 10, default: '0'
  end

  def down
    change_column :elections, :protocol_top_box_margin, :integer, default: 0
    change_column :elections, :protocol_party_top_margin, :integer, default: 0
  end
end
