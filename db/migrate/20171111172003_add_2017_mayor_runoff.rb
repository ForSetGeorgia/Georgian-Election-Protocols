class Add2017MayorRunoff < ActiveRecord::Migration
  def up
    csv_path = "#{Rails.root}/db/data/2017/"

    Election.transaction do
      election = Election.new(
        can_enter_data: false,
        election_at: '2017-11-12',
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
        party_file: File.open("#{csv_path}2017_mayor_runoff_parties.csv"),
        district_precinct_file: File.open("#{csv_path}2017_mayor_runoff_districts_precincts.csv"),
        party_district_file: File.open("#{csv_path}2017_mayor_runoff_districts_parties.csv"),
        tmp_analysis_table_name: '2017 Mayor Runoff'
      )
      election.election_translations.build(locale: 'en', name: '2017 Self-Governing City Mayor Runoff Election')
      election.election_translations.build(locale: 'ka', name: '2017 წლის თვითმმართველი ქალაქის მერის მეორე ტური')
      election.save

    end
  end

  def down
    election = Election.includes(:election_translations).where(election_translations: {name: '2017 Self-Governing City Mayor Runoff Election'}).first
    election.destroy if election.present?
  end
end
