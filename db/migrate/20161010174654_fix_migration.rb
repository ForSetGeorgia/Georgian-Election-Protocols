class FixMigration < ActiveRecord::Migration
  def up
    # need to re-create the views
    election = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Majoritarian'}).first
    election.create_analysis_views

  end

  def down
    puts "do nothing"
  end
end
