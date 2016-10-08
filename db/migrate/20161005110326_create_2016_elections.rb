# encoding: UTF-8
class Create2016Elections < ActiveRecord::Migration
  def up
    require 'csv'
    csv_path = "#{Rails.root}/db/data/2016/"
    now = Time.now
    client = ActiveRecord::Base.connection
    analysis_db = 'protocol_analysis'

    Election.transaction do

      # prop
      puts '- party list election'
      prop = Election.new(can_enter_data: false, election_at: '2016-10-08', election_app_event_id: 45,
                          has_regions: false, has_district_names: false)
      prop.election_translations.build(locale: 'en', name: '2016 Parliamentary - Party List')
      prop.election_translations.build(locale: 'ka', name: '2016 წლის საპარლამენტო არჩევნები - პარტიული სია')
      prop.save
      # major
      puts '- major election'
      major = Election.new(can_enter_data: false, election_at: '2016-10-08', election_app_event_id: 46,
                          has_regions: false, has_district_names: false, parties_same_for_all_districts: false)
      major.election_translations.build(locale: 'en', name: '2016 Parliamentary - Majoritarian')
      major.election_translations.build(locale: 'ka', name: '2016 წლის საპარლამენტო არჩევნები - მაჟორიტარული')
      major.save

      # load parties for prop
      puts '- parties for party list'
      csv_data = CSV.read(csv_path + '2016_party_list_parties.csv')
      csv_data.each_with_index do |row, i|
        if i > 0
          p = prop.parties.create(number: row[0])
          p.party_translations.create(locale: 'en', name: row[1])
          p.party_translations.create(locale: 'ka', name: row[1])
        end
      end
      puts '-> creating party list analysis tables/views'
      prop.create_analysis_items

      # load parties for major
      puts '- parties for major'
      csv_data = CSV.read(csv_path + '2016_major_parties.csv')
      csv_data.each_with_index do |row, i|
        if i > 0
          is_independent = row[2].present? && row[2].to_s.downcase == 'true'
          p = major.parties.create(number: row[0], is_independent: is_independent)
          p.party_translations.create(locale: 'en', name: row[1])
          p.party_translations.create(locale: 'ka', name: row[1])
        end
      end
      puts '-> creating major analysis tables/views'
      major.create_analysis_items

      # assign districts to party for major
      puts '- assign districts to party for major'
      csv_data = CSV.read(csv_path + '2016_district_major_parties.csv')
      sql_values = []
      csv_data.each_with_index do |row, i|
        if i > 0
          sql_values << "(#{major.id}, #{row[0]}, #{row[1]}, '#{now}')"
          # major.district_parties.create(district_id: row[0], party_id: row[1])
        end
      end
      client.execute("insert into district_parties
        (`election_id`, `district_id`, `party_number`, `created_at`)
        values #{sql_values.join(', ')}"
      )

      # load precincts/districts
      puts '- assign precincts/districts for both elections'
      csv_data = CSV.read(csv_path + '2016_districts_precincts.csv')
      sql_values = []
      csv_data.each_with_index do |row, i|
        if i > 0
          sql_values << "(#{prop.id}, #{row[0]}, #{row[1]}, '#{now}')"
          sql_values << "(#{major.id}, #{row[0]}, #{row[1]}, '#{now}')"
        end
      end
      client.execute("insert into district_precincts
        (`election_id`, `district_id`, `precinct_id`, `created_at`)
        values #{sql_values.join(', ')}"
      )
      puts "- assign region names to district/precincts"
      prop.assign_region_names
      major.assign_region_names

      # create precinct counts
      puts '- creating party list anaylsis precinct count records'
      prop.create_analysis_precinct_counts
      puts '- creating major anaylsis precinct count records'
      major.create_analysis_precinct_counts

      admins = User.where(role: 99)
      if admins.present?
        puts '- assign admin users to party list and major'
        admins.each do |admin|
          prop.users << admin
          major.users << admin
        end
      end
    end
  end

  def down
    Election.transaction do
      e_ids = Election.where(election_at: '2016-10-08').pluck(:id)
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
