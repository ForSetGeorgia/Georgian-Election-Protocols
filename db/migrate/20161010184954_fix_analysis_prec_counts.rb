class FixAnalysisPrecCounts < ActiveRecord::Migration
  def up
    election = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Party List'}).first
    election.create_analysis_precinct_counts
    election = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Majoritarian'}).first
    election.create_analysis_precinct_counts
  end

  def down
    puts "do nothing"
  end
end
