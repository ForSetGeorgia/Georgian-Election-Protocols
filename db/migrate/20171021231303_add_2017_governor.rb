class Add2017Governor < ActiveRecord::Migration
  def up
    csv_path = "#{Rails.root}/db/data/2017/"

    Election.transaction do
      election = Election.new(
        can_enter_data: false,
        election_at: '2017-10-21',
        election_app_event_id: nil,
        parties_same_for_all_districts: false,
        district_precinct_separator: '-',
        has_regions: false,
        has_district_names: true,
        has_custom_shape_levels: true,
        has_indepenedent_parties: true,
        is_local_majoritarian: false,
        # protocol_top_box_margin: '114',
        # protocol_party_top_margin: '2.5',
        party_file: File.open("#{csv_path}2017_governor_parties.csv"),
        district_precinct_file: File.open("#{csv_path}2017_districts_precincts.csv"),
        party_district_file: File.open("#{csv_path}2017_governor_districts_parties.csv"),
        tmp_analysis_table_name: '2017 Governor'
      )
      election.election_translations.build(locale: 'en', name: '2017 Governor Election')
      election.election_translations.build(locale: 'ka', name: '2014 წლის გამგებლის არჩევნები')
      election.save

    end
  end

  def down
    election = Election.includes(:election_translations).where(election_translations: {name: '2017 Governor Election'}).first
    election.destroy if election.present?
  end
end
