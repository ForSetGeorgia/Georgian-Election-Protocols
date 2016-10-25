class AddRunoff < ActiveRecord::Migration
  def up
    csv_path = "#{Rails.root}/db/data/2016/"

    Election.transaction do
      puts '-----------------------'
      puts '-----------------------'
      puts '- creating election'
      puts '-----------------------'
      puts '-----------------------'
      election = Election.new(
        can_enter_data: false,
        election_at: '2016-10-30',
        election_app_event_id: 50,
        parties_same_for_all_districts: false,
        district_precinct_separator: '.',
        has_regions: false,
        has_district_names: false,
        has_custom_shape_levels: false,
        has_indepenedent_parties: true,
        is_local_majoritarian: false,
        protocol_top_box_margin: '114',
        protocol_party_top_margin: '2.5',
        party_file: File.open("#{csv_path}2016_major_parties_runoff.csv"),
        district_precinct_file: File.open("#{csv_path}2016_districts_precincts_major_runoff.csv"),
        party_district_file: File.open("#{csv_path}2016_district_major_runoff_parties.csv"),
        tmp_analysis_table_name: '2016 Parliamentary - Majr Runoff'
      )
      election.election_translations.build(locale: 'en', name: '2016 Parliamentary - Majoritarian Runoff')
      election.election_translations.build(locale: 'ka', name: '2016 წლის საპარლამენტო არჩევნები - მაჟორიტარული არჩევნების მეორე ტური')
      election.save

      puts '-----------------------'
      puts '-----------------------'
      puts '- setting max party in district to 16'
      puts '-----------------------'
      puts '-----------------------'
      # hard code max_party_in_district since the protocol is using the same design as the original majoritiatrian protocol
      # even though there are only 2 parties per district
      election.reset_max_party_num = false
      election.max_party_in_district = 16
      election.save
    end
  end

  def down
    election = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Majoritarian Runoff'}).first
    election.destroy if election.present?
  end
end
