class AddAttachmentPartiesToElections < ActiveRecord::Migration
  def self.up
    change_table :elections do |t|
      t.attachment :party_file
    end
  end

  def self.down
    drop_attached_file :elections, :party_file
  end
end
