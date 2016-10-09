class FixDistParty < ActiveRecord::Migration
  def up
    remove_index "district_parties", :name => "index_district_parties_on_election_id_and_district_id"
    change_column :district_parties, :district_id, 'VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci'
    add_index "district_parties", ["election_id", "district_id"], :name => "index_district_parties_elec_id_dist_id"

    # reload the data
    client = ActiveRecord::Base.connection
    now = Time.now
    csv_path = "#{Rails.root}/db/data/2016/"

    DistrictParty.delete_all

    major = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Majoritarian'}).first

    # assign districts to party for major
    puts '- assign districts to party for major'
    csv_data = CSV.read(csv_path + '2016_district_major_parties.csv')
    sql_values = []
    csv_data.each_with_index do |row, i|
      if i > 0
        sql_values << "(#{major.id}, '#{row[0]}', '#{row[1]}', '#{now}')"
      end
    end
    client.execute("insert into district_parties
      (`election_id`, `district_id`, `party_number`, `created_at`)
      values #{sql_values.join(', ')}"
    )

  end

  def down
    remove_index "district_parties", :name => "index_district_parties_elec_id_dist_id"
    change_column :district_parties, :district_id, 'VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci'
    add_index "district_parties", ["election_id", "district_id"], :name => "index_district_parties_on_election_id_and_district_id"
  end
end
