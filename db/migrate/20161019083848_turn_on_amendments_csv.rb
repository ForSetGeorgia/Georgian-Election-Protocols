class TurnOnAmendmentsCsv < ActiveRecord::Migration
  def up
    prop = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Party List'}).first
    major = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Majoritarian'}).first

    prop.create_analysis_views
    major.create_analysis_views
  end

  def down
    puts "do nothing"
  end
end
