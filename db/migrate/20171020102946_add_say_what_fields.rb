class AddSayWhatFields < ActiveRecord::Migration
  def change
    add_column :district_precincts, :has_say_what, :boolean, default: false
    add_column :district_precincts, :say_what_notes, :text
    add_column :district_precincts, :say_what_reported_at, :datetime
    add_column :district_precincts, :last_say_what_update_by_user_id, :integer
    add_column :district_precincts, :last_say_what_updated_at, :datetime

    add_index :district_precincts, [:has_say_what, :say_what_reported_at], name: :idx_say_what
  end
end
