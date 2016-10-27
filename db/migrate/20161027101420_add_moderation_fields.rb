class AddModerationFields < ActiveRecord::Migration
  def change
    add_column :district_precincts, :being_moderated, :boolean
    add_column :district_precincts, :moderation_reason, :string
    add_index :district_precincts, :being_moderated
  end
end
