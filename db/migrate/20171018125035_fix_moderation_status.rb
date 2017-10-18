class FixModerationStatus < ActiveRecord::Migration
  def up
    DistrictPrecinct.where(being_moderated: true).where('moderation_status > 0').update_all(being_moderated: false)
  end

  def down
    puts "do nothing"
  end
end
