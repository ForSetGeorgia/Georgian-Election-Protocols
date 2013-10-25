class President2013 < ActiveRecord::Base
  require 'csv'

  after_create :notify_if_can_migrate


  #####################
  #####################

  # if there are enough precincts on file since the last migraiton, 
  # send notification
  def notify_if_can_migrate

    last_precinct_count = ElectionDataMigration.last_precinct_count
    precinct_count = President2013.count
    
    if (precinct_count - last_precinct_count) == ElectionDataMigration::MIN_PRECINCTS_CHANGE
      message = Message.new
      message.locale = I18n.locale
      message.subject = I18n.t("mailer.notification.can_migrate.subject", :locale => I18n.locale, :env => Rails.env, :app_name => I18n.t('app.common.app_name'))
      message.message = I18n.t("mailer.notification.can_migrate.message", :locale => I18n.locale)

      NotificationMailer.can_migrate(message).deliver
    end
    
  end
  
  #####################
  #####################

  def calculate_valid_votes
    sum = 0
    sum += self.num_votes.present? ? self.num_votes : 0
    sum -= self.num_invalid_votes.present? ? self.num_invalid_votes : 0
    
    return sum
  end
  
  def calculate_logic_check_fail
    calculate_valid_votes - sum_party_votes == 0 ? false : true
  end
  
  def calculate_logic_check_difference
    calculate_valid_votes - sum_party_votes
  end
  
  def calculate_more_ballots_than_votes_flag
    calculate_valid_votes > sum_party_votes ? true : false
  end
  
  def calculate_more_ballots_than_votes
    if calculate_more_ballots_than_votes_flag
      calculate_valid_votes - sum_party_votes
    else
      0
    end
  end
  
  def calculate_more_votes_than_ballots_flag
    calculate_valid_votes < sum_party_votes ? true : false
  end
  
  def calculate_more_votes_than_ballots
    if calculate_more_votes_than_ballots_flag
      (calculate_valid_votes - sum_party_votes).abs
    else
      0
    end
  end
  
  def sum_party_votes
    sum = 0
    sum += self['1 - Tamaz Bibiluri'].present? ? self['1 - Tamaz Bibiluri'] : 0
    sum += self['2 - Giorgi Liluashvili'].present? ? self['2 - Giorgi Liluashvili'] : 0
    sum += self['3 - Sergo Javakhidze'].present? ? self['3 - Sergo Javakhidze'] : 0
    sum += self['4 - Koba Davitashvili'].present? ? self['4 - Koba Davitashvili'] : 0
    sum += self['5 - Davit Bakradze'].present? ? self['5 - Davit Bakradze'] : 0
    sum += self['6 - Akaki Asatiani'].present? ? self['6 - Akaki Asatiani'] : 0
    sum += self['7 - Nino Chanishvili'].present? ? self['7 - Nino Chanishvili'] : 0
    sum += self['8 - Teimuraz Bobokhidze'].present? ? self['8 - Teimuraz Bobokhidze'] : 0
    sum += self['9 - Shalva Natelashvili'].present? ? self['9 - Shalva Natelashvili'] : 0
    sum += self['10 - Giorgi Targamadze'].present? ? self['10 - Giorgi Targamadze'] : 0
    sum += self['11 - Levan Chachua'].present? ? self['11 - Levan Chachua'] : 0
    sum += self['12 - Nestan Kirtadze'].present? ? self['12 - Nestan Kirtadze'] : 0
    sum += self['13 - Giorgi Chikhladze'].present? ? self['13 - Giorgi Chikhladze'] : 0
    sum += self['14 - Nino Burjanadze'].present? ? self['14 - Nino Burjanadze'] : 0
    sum += self['15 - Zurab Kharatishvili'].present? ? self['15 - Zurab Kharatishvili'] : 0
    sum += self['16 - Mikheil Saluashvili'].present? ? self['16 - Mikheil Saluashvili'] : 0
    sum += self['17 - Kartlos Gharibashvili'].present? ? self['17 - Kartlos Gharibashvili'] : 0
    sum += self['18 - Mamuka Chokhonelidze'].present? ? self['18 - Mamuka Chokhonelidze'] : 0
    sum += self['19 - Avtandil Margiani'].present? ? self['19 - Avtandil Margiani'] : 0
    sum += self['20 - Nugzar Avaliani'].present? ? self['20 - Nugzar Avaliani'] : 0
    sum += self['21 - Mamuka Melikishvili'].present? ? self['21 - Mamuka Melikishvili'] : 0
    sum += self['22 - Teimuraz Mzhavia'].present? ? self['22 - Teimuraz Mzhavia'] : 0
    sum += self['41 - Giorgi Margvelashvili'].present? ? self['41 - Giorgi Margvelashvili'] : 0

    return sum
  end
  
  
  #####################
  #####################

  def self.precinct_data
    select("region, district_id, district_name, precinct_id, attached_precinct_id, num_possible_voters, num_special_voters, num_at_12, num_at_17, num_votes, num_ballots, num_invalid_votes, `1 - Tamaz Bibiluri`, `2 - Giorgi Liluashvili`, `3 - Sergo Javakhidze`, `4 - Koba Davitashvili`, `5 - Davit Bakradze`, `6 - Akaki Asatiani`, `7 - Nino Chanishvili`, `8 - Teimuraz Bobokhidze`, `9 - Shalva Natelashvili`, `10 - Giorgi Targamadze`, `11 - Levan Chachua`, `12 - Nestan Kirtadze`, `13 - Giorgi Chikhladze`, `14 - Nino Burjanadze`, `15 - Zurab Kharatishvili`, `16 - Mikheil Saluashvili`, `17 - Kartlos Gharibashvili`, `18 - Mamuka Chokhonelidze`, `19 - Avtandil Margiani`, `20 - Nugzar Avaliani`, `21 - Mamuka Melikishvili`, `22 - Teimuraz Mzhavia`, `41 - Giorgi Margvelashvili`").order('district_id, precinct_id')
  end

  def self.download_precinct_data
		csv_data = CSV.generate(:col_sep=>',') do |csv|
      # add header
      row = []
      row << I18n.t('app.csv_header.region')
      row << I18n.t('app.csv_header.district_id')
      row << I18n.t('app.csv_header.district_name')
      row << I18n.t('app.csv_header.precinct_id')
      row << I18n.t('app.csv_header.attached_precinct_id')
      row << I18n.t('app.csv_header.num_possible_voters')
      row << I18n.t('app.csv_header.num_special_voters')
      row << I18n.t('app.csv_header.num_at_12')
      row << I18n.t('app.csv_header.num_at_17')
      row << I18n.t('app.csv_header.num_votes')
      row << I18n.t('app.csv_header.num_ballots')
      row << I18n.t('app.csv_header.num_invalid_votes')
      row << I18n.t('app.csv_header.1_Tamaz_Bibiluri')
      row << I18n.t('app.csv_header.2_Giorgi_Liluashvili')
      row << I18n.t('app.csv_header.3_Sergo_Javakhidze')
      row << I18n.t('app.csv_header.4_Koba_Davitashvili')
      row << I18n.t('app.csv_header.5_Davit_Bakradze')
      row << I18n.t('app.csv_header.6_Akaki_Asatiani')
      row << I18n.t('app.csv_header.7_Nino_Chanishvili')
      row << I18n.t('app.csv_header.8_Teimuraz_Bobokhidze')
      row << I18n.t('app.csv_header.9_Shalva_Natelashvili')
      row << I18n.t('app.csv_header.10_Giorgi_Targamadze')
      row << I18n.t('app.csv_header.11_Levan_Chachua')
      row << I18n.t('app.csv_header.12_Nestan_Kirtadze')
      row << I18n.t('app.csv_header.13_Giorgi_Chikhladze')
      row << I18n.t('app.csv_header.14_Nino_Burjanadze')
      row << I18n.t('app.csv_header.15_Zurab_Kharatishvili')
      row << I18n.t('app.csv_header.16_Mikheil_Saluashvili')
      row << I18n.t('app.csv_header.17_Kartlos_Gharibashvili')
      row << I18n.t('app.csv_header.18_Mamuka_Chokhonelidze')
      row << I18n.t('app.csv_header.19_Avtandil_Margiani')
      row << I18n.t('app.csv_header.20_Nugzar_Avaliani')
      row << I18n.t('app.csv_header.21_Mamuka_Melikishvili')
      row << I18n.t('app.csv_header.22_Teimuraz_Mzhavia')
      row << I18n.t('app.csv_header.41_Giorgi_Margvelashvili')      
      csv << row
      
      
      # add data
      President2013.precinct_data.find_each do |precinct|
        row = []
        row << precinct["region"]
        row << precinct["district_id"]
        row << precinct["district_name"]
        row << precinct["precinct_id"]
        row << precinct["attached_precinct_id"]
        row << precinct["num_possible_voters"]
        row << precinct["num_special_voters"]
        row << precinct["num_at_12"]
        row << precinct["num_at_17"]
        row << precinct["num_votes"]
        row << precinct["num_ballots"]
        row << precinct["num_invalid_votes"]
        row << precinct["1 - Tamaz Bibiluri"]
        row << precinct["2 - Giorgi Liluashvili"]
        row << precinct["3 - Sergo Javakhidze"]
        row << precinct["4 - Koba Davitashvili"]
        row << precinct["5 - Davit Bakradze"]
        row << precinct["6 - Akaki Asatiani"]
        row << precinct["7 - Nino Chanishvili"]
        row << precinct["8 - Teimuraz Bobokhidze"]
        row << precinct["9 - Shalva Natelashvili"]
        row << precinct["10 - Giorgi Targamadze"]
        row << precinct["11 - Levan Chachua"]
        row << precinct["12 - Nestan Kirtadze"]
        row << precinct["13 - Giorgi Chikhladze"]
        row << precinct["14 - Nino Burjanadze"]
        row << precinct["15 - Zurab Kharatishvili"]
        row << precinct["16 - Mikheil Saluashvili"]
        row << precinct["17 - Kartlos Gharibashvili"]
        row << precinct["18 - Mamuka Chokhonelidze"]
        row << precinct["19 - Avtandil Margiani"]
        row << precinct["20 - Nugzar Avaliani"]
        row << precinct["21 - Mamuka Melikishvili"]
        row << precinct["22 - Teimuraz Mzhavia"]
        row << precinct["41 - Giorgi Margvelashvili"]
        csv << row
              
      end
    end
    return csv_data
  end
  
  
  # call the csv view to get the complete dataset to load into the election map application
  def self.download_election_map_data
		csv_data = CSV.generate(:col_sep=>',') do |csv|
      # add header
      row = ['shape', 'common_id', 'common_name', 'Total Voter Turnout (#)', 'Total Voter Turnout (%)', 'Number of Precincts with Invalid Ballots from 0-1%', 'Number of Precincts with Invalid Ballots from 1-3%', 'Number of Precincts with Invalid Ballots from 3-5%', 'Number of Precincts with Invalid Ballots > 5%', 'Invalid Ballots (%)', 'Precincts with More Ballots Than Votes (#)', 'Precincts with More Ballots Than Votes (%)', 'More Ballots Than Votes (Average)', 'More Ballots Than Votes (#)','Precincts with More Votes than Ballots (#)', 'Precincts with More Votes than Ballots (%)', 'More Votes than Ballots (Average)', 'More Votes than Ballots (#)','Average votes per minute (08:00-12:00)', 'Average votes per minute (12:00-17:00)', 'Average votes per minute (17:00-20:00)', 'Number of Precincts with votes per minute > 2 (08:00-12:00)', 'Number of Precincts with votes per minute > 2 (12:00-17:00)', 'Number of Precincts with votes per minute > 2 (17:00-20:00)', 'Number of Precincts with votes per minute > 2', 'Precincts Reported (#)', 'Precincts Reported (%)', 'Tamaz Bibiluri', 'Giorgi Liluashvili', 'Sergo Javakhidze', 'Koba Davitashvili', 'Davit Bakradze', 'Akaki Asatiani', 'Nino Chanishvili', 'Teimuraz Bobokhidze', 'Shalva Natelashvili', 'Giorgi Targamadze', 'Levan Chachua', 'Nestan Kirtadze', 'Giorgi Chikhladze', 'Nino Burjanadze', 'Zurab Kharatishvili', 'Mikheil Saluashvili', 'Kartlos Gharibashvili', 'Mamuka Chokhonelidze', 'Avtandil Margiani', 'Nugzar Avaliani', 'Mamuka Melikishvili', 'Teimuraz Mzhavia', 'Giorgi Margvelashvili']
      csv << row
        
      # add the data
      sql = "select * from `president2013s - csv`"
      data = ActiveRecord::Base.connection.select_all(sql)
      
      if data.present?
        data.each do |data_row|
          row = []
          row << data_row['shape']
          row << data_row['common_id']
          row << data_row['common_name']
          row << data_row['Total Voter Turnout (#)']
          row << data_row['Total Voter Turnout (%)']
          row << data_row['Number of Precincts with Invalid Ballots from 0-1%']
          row << data_row['Number of Precincts with Invalid Ballots from 1-3%']
          row << data_row['Number of Precincts with Invalid Ballots from 3-5%']
          row << data_row['Number of Precincts with Invalid Ballots > 5%']
          row << data_row['Invalid Ballots (%)']
          row << data_row['Precincts with More Ballots Than Votes (#)']
          row << data_row['Precincts with More Ballots Than Votes (%)']
          row << data_row['More Ballots Than Votes (Average)']
          row << data_row['More Ballots Than Votes (#)']
          row << data_row['Precincts with More Votes than Ballots (#)']
          row << data_row['Precincts with More Votes than Ballots (%)']
          row << data_row['More Votes than Ballots (Average)']
          row << data_row['More Votes than Ballots (#)']
          row << data_row['Average votes per minute (08:00-12:00)']
          row << data_row['Average votes per minute (12:00-17:00)']
          row << data_row['Average votes per minute (17:00-20:00)']
          row << data_row['Number of Precincts with votes per minute > 2 (08:00-12:00)']
          row << data_row['Number of Precincts with votes per minute > 2 (12:00-17:00)']
          row << data_row['Number of Precincts with votes per minute > 2 (17:00-20:00)']
          row << data_row['Number of Precincts with votes per minute > 2']
          row << data_row['Precincts Reported (#)']
          row << data_row['Precincts Reported (%)']
          row << data_row['Tamaz Bibiluri']
          row << data_row['Giorgi Liluashvili']
          row << data_row['Sergo Javakhidze']
          row << data_row['Koba Davitashvili']
          row << data_row['Davit Bakradze']
          row << data_row['Akaki Asatiani']
          row << data_row['Nino Chanishvili']
          row << data_row['Teimuraz Bobokhidze']
          row << data_row['Shalva Natelashvili']
          row << data_row['Giorgi Targamadze']
          row << data_row['Levan Chachua']
          row << data_row['Nestan Kirtadze']
          row << data_row['Giorgi Chikhladze']
          row << data_row['Nino Burjanadze']
          row << data_row['Zurab Kharatishvili']
          row << data_row['Mikheil Saluashvili']
          row << data_row['Kartlos Gharibashvili']
          row << data_row['Mamuka Chokhonelidze']
          row << data_row['Avtandil Margiani']
          row << data_row['Nugzar Avaliani']
          row << data_row['Mamuka Melikishvili']
          row << data_row['Teimuraz Mzhavia']
          row << data_row['Giorgi Margvelashvili']

          csv << row
        end
      end

    end  
  end
end
