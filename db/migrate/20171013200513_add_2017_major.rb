class Add2017Major < ActiveRecord::Migration
  def up
    csv_path = "#{Rails.root}/db/data/2017/"

    Election.transaction do
      election = Election.new(
        can_enter_data: false,
        election_at: '2017-10-21',
        # election_app_event_id: 49,
        parties_same_for_all_districts: false,
        district_precinct_separator: '-',
        has_regions: false,
        has_district_names: false,
        has_custom_shape_levels: true,
        has_indepenedent_parties: true,
        is_local_majoritarian: true,
        # protocol_top_box_margin: '114',
        # protocol_party_top_margin: '2.5',
        party_file: File.open("#{csv_path}2017_major_parties.csv"),
        district_precinct_file: File.open("#{csv_path}2017_major_districts_precincts.csv"),
        party_district_file: File.open("#{csv_path}2017_major_districts_parties.csv"),
        tmp_analysis_table_name: '2017 Local - Major'
      )
      election.election_translations.build(locale: 'en', name: '2017 Local Election - Majoritarian')
      election.election_translations.build(locale: 'ka', name: '2017 წლის ადგილობრივი თვითმმართველობის არჩევნები - მაჟორიტარული')
      election.save

    end
  end

  def down
    election = Election.includes(:election_translations).where(election_translations: {name: '2017 Local Election - Majoritarian'}).first
    election.destroy
  end
end
