class ReloadDistricts < ActiveRecord::Migration
  def up
    csv_path = "#{Rails.root}/db/data/2017/"

    # assign the correct districts/precincts to mayor and governor
    Election.transaction do
      election = Election.includes(:election_translations).where(election_translations: {name: '2017 Mayor Election'}).first
      if election.present?
        election.district_precinct_file = File.open("#{csv_path}2017_mayor_districts_precincts.csv")
        election.save
      end
    end

    Election.transaction do
      election = Election.includes(:election_translations).where(election_translations: {name: '2017 Governor Election'}).first
      if election.present?
        election.district_precinct_file = File.open("#{csv_path}2017_governor_districts_precincts.csv")
        election.save
      end
    end

  end

  def down
    csv_path = "#{Rails.root}/db/data/2017/"

    Election.transaction do
      election = Election.includes(:election_translations).where(election_translations: {name: '2017 Mayor Election'}).first
      if election.present?
        election.district_precinct_file = File.open("#{csv_path}2017_districts_precincts.csv")
        election.save
      end
    end

    Election.transaction do
      election = Election.includes(:election_translations).where(election_translations: {name: '2017 Governor Election'}).first
      if election.present?
        election.district_precinct_file = File.open("#{csv_path}2017_districts_precincts.csv")
        election.save
      end
    end
  end
end
