class AddAttachmentPartyDistrictsToElections < ActiveRecord::Migration
  def self.up
    change_table :elections do |t|
      t.attachment :party_district_file
    end
  end

  def self.down
    drop_attached_file :elections, :party_district_file
  end
end
