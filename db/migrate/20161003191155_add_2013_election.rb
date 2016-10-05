class Add2013Election < ActiveRecord::Migration
  def up
    require 'csv'
    csv_path = "#{Rails.root}/db/data/2013/"

    Election.transaction do
      puts '- creating election'
      e = Election.new(can_enter_data: false, election_at: '2013-10-27', election_app_event_id: 38,
                          has_regions: true, has_district_names: true)
      e.election_translations.build(locale: 'en', name: '2013 Presidential')
      e.election_translations.build(locale: 'ka', name: '2013 წლის საპრეზიდენტო არჩევნები')
      e.save

      puts '- assigning users to election'
      e.users << User.all

      puts '- assigning id to crowd data, queue, etc'
      CrowdDatum.where(election_id: nil).update_all(election_id: e.id)
      CrowdQueue.where(election_id: nil).update_all(election_id: e.id)
      ElectionDataMigration.where(election_id: nil).update_all(election_id: e.id)
      HasProtocol.where(election_id: nil).update_all(election_id: e.id)
      DistrictPrecinct.where(election_id: nil).update_all(election_id: e.id)

      puts '- creating party list'
      csv_data = CSV.read(csv_path + '2013_pres_parties.csv')
      csv_data.each_with_index do |row, i|
        if i > 0
          p = e.parties.create(number: row[0])
          p.party_translations.create(locale: 'en', name: row[1])
          p.party_translations.create(locale: 'ka', name: row[1])
        end
      end
      puts '-> creating analysis tables/views'
      e.create_analysis_items

      puts "- assign region names to district/precincts"
      e.assign_region_names

      # create precinct counts
      puts '-> creating anaylsis precinct count records'
      e.create_analysis_precinct_counts

      # copy data from president2013 to the analysis raw table
      puts '- copying data from president2013 to analysis raw table'
      client = ActiveRecord::Base.connection
      sql = "insert into `#{e.analysis_table_name} - raw`
            (
            `region`, `district_id`, `district_name`, `precinct_id`, `attached_precinct_id`,
            `num_possible_voters`, `num_special_voters`, `num_at_12`, `num_at_17`, `num_votes`, `num_ballots`,
            `num_invalid_votes`, `num_valid_votes`, `logic_check_fail`, `logic_check_difference`,
            `more_ballots_than_votes_flag`, `more_ballots_than_votes`, `more_votes_than_ballots_flag`, `more_votes_than_ballots`,
            `1 - Tamaz Bibiluri`, `2 - Giorgi Liluashvili`, `3 - Sergo Javakhidze`, `4 - Koba Davitashvili`, `5 - Davit Bakradze`,
            `6 - Akaki Asatiani`, `7 - Nino Chanishvili`, `8 - Teimuraz Bobokhidze`, `9 - Shalva Natelashvili`,
            `10 - Giorgi Targamadze`, `11 - Levan Chachua`, `12 - Nestan Kirtadze`, `13 - Giorgi Chikhladze`,
            `14 - Nino Burjanadze`, `15 - Zurab Kharatishvili`, `16 - Mikheil Saluashvili`, `17 - Kartlos Gharibashvili`,
            `18 - Mamuka Chokhonelidze`, `19 - Avtandil Margiani`, `20 - Nugzar Avaliani`, `21 - Mamuka Melikishvili`,
            `22 - Teimuraz Mzhavia`, `41 - Giorgi Margvelashvili`
            )
            select
            `region`, `district_id`, `district_name`, `precinct_id`, `attached_precinct_id`,
            `num_possible_voters`, `num_special_voters`, `num_at_12`, `num_at_17`, `num_votes`, `num_ballots`,
            `num_invalid_votes`, `num_valid_votes`, `logic_check_fail`, `logic_check_difference`,
            `more_ballots_than_votes_flag`, `more_ballots_than_votes`, `more_votes_than_ballots_flag`, `more_votes_than_ballots`,
            `1 - Tamaz Bibiluri`, `2 - Giorgi Liluashvili`, `3 - Sergo Javakhidze`, `4 - Koba Davitashvili`, `5 - Davit Bakradze`,
            `6 - Akaki Asatiani`, `7 - Nino Chanishvili`, `8 - Teimuraz Bobokhidze`, `9 - Shalva Natelashvili`,
            `10 - Giorgi Targamadze`, `11 - Levan Chachua`, `12 - Nestan Kirtadze`, `13 - Giorgi Chikhladze`,
            `14 - Nino Burjanadze`, `15 - Zurab Kharatishvili`, `16 - Mikheil Saluashvili`, `17 - Kartlos Gharibashvili`,
            `18 - Mamuka Chokhonelidze`, `19 - Avtandil Margiani`, `20 - Nugzar Avaliani`, `21 - Mamuka Melikishvili`,
            `22 - Teimuraz Mzhavia`, `41 - Giorgi Margvelashvili`
            from president2013s"
      client.execute(sql)
    end
  end

  def down
    Election.transaction do
      e_ids = Election.where(election_at: '2013-10-27').pluck(:id)
      puts "deleting elections with id #{e_ids}"
      DistrictPrecinct.where(election_id: e_ids).update_all(election_id: nil)
      CrowdQueue.where(election_id: e_ids).update_all(election_id: nil)
      CrowdDatum.where(election_id: e_ids).update_all(election_id: nil)
      HasProtocol.where(election_id: e_ids).update_all(election_id: nil)
      ElectionTranslation.where(election_id: e_ids).delete_all
      DistrictParty.where(election_id: e_ids).delete_all
      Party.where(election_id: e_ids).delete_all
      ElectionUser.where(election_id: e_ids).delete_all
      e = Election.where(id: e_ids)
      if e.present?
        e.each{|x|
          x.delete_analysis_items
          x.delete
        }
      end
    end
  end
end
