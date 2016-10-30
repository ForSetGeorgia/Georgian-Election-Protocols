class AddMoreModerationFields < ActiveRecord::Migration
  def change
    add_column :district_precincts, :issue_reported_by_user_id, :integer
    add_column :district_precincts, :issue_reported_at, :datetime

    add_column :district_precincts, :last_moderation_update_by_user_id, :integer
    add_column :district_precincts, :last_moderation_updated_at, :datetime

    add_column :district_precincts, :moderation_status, :integer
    add_column :district_precincts, :moderation_notes, :text

    add_index :district_precincts, :issue_reported_at
    add_index :district_precincts, :last_moderation_updated_at
    add_index :district_precincts, :moderation_status

  end
end
