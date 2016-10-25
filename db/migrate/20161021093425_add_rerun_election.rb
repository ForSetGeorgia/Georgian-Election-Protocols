class AddRerunElection < ActiveRecord::Migration
  def up
    csv_path = "#{Rails.root}/db/data/2016/"

    Election.transaction do
      election = Election.new(
        can_enter_data: false,
        election_at: '2016-10-22',
        election_app_event_id: 49,
        parties_same_for_all_districts: false,
        district_precinct_separator: '.',
        has_regions: false,
        has_district_names: false,
        has_custom_shape_levels: false,
        has_indepenedent_parties: false,
        is_local_majoritarian: false,
        protocol_top_box_margin: '114',
        protocol_party_top_margin: '2.5',
        party_file: File.open("#{csv_path}2016_major_parties_rerun.csv"),
        district_precinct_file: File.open("#{csv_path}2016_districts_precincts_major_rerun.csv"),
        party_district_file: File.open("#{csv_path}2016_district_major_rerun_parties.csv"),
        tmp_analysis_table_name: '2016 Parliamentary - Major Rerun'
      )
      election.election_translations.build(locale: 'en', name: '2016 Parliamentary - Majoritarian Rerun')
      election.election_translations.build(locale: 'ka', name: '2016 წლის საპარლამენტო არჩევნები - მაჟორიტარული არჩევნების განმეორებითი კენჭისყრა')
      election.save

    end
  end

  def down
    election = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Majoritarian Rerun'}).first
    election.destroy
  end
end
