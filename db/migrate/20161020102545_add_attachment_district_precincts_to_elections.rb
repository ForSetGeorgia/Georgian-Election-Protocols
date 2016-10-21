class AddAttachmentDistrictPrecinctsToElections < ActiveRecord::Migration
  def self.up
    change_table :elections do |t|
      t.attachment :district_precinct_file
    end
  end

  def self.down
    drop_attached_file :elections, :district_precinct_file
  end
end
