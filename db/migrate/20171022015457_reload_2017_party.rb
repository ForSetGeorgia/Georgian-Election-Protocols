class Reload2017Party < ActiveRecord::Migration
  def up
    csv_path = "#{Rails.root}/db/data/2017/"

    # the cec is recording mayors and governonrs separately
    # so the mayor files need to be reloaded
    Election.transaction do
      election = Election.includes(:election_translations).where(election_translations: {name: '2017 Local Election - Party List'}).first
      if election.present?
        election.parties_same_for_all_districts = false
        election.party_file = File.open("#{csv_path}2017_party_list_parties.csv")
        election.district_precinct_file = File.open("#{csv_path}2017_districts_precincts.csv")
        election.party_district_file = File.open("#{csv_path}2017_party_list_districts_parties.csv")
        election.save
      end
    end
  end

  def down
    csv_path = "#{Rails.root}/db/data/2017/"

    Election.transaction do
      election = Election.includes(:election_translations).where(election_translations: {name: '2017 Local Election - Party List'}).first
      if election.present?
        election.parties_same_for_all_districts = false
        election.party_file = File.open("#{csv_path}2017_party_list_parties.csv")
        election.district_precinct_file = File.open("#{csv_path}2017_districts_precincts.csv")
        election.party_district_file = File.open("#{csv_path}2017_party_list_districts_parties.csv")
        election.save
      end
    end
  end
end
