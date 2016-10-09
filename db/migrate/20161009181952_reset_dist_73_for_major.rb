class ResetDist73ForMajor < ActiveRecord::Migration
  def up
    client = ActiveRecord::Base.connection
    now = Time.now
    csv_path = "#{Rails.root}/db/data/2016/"

    # district 73 was missing a party
    # - reload all parties
    # - delete all entries for this district since they cannot be correct

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

    HasProtocol.delete_all
    dp = DistrictPrecinct.where(election_id: major.id, district_id: '73')

    # load all districts/precincts that have amendment
    puts 'loading ids into temp table'
    sql = "insert into has_protocols (election_id, district_id, precinct_id) values "
    sql << dp.map{|x| "(#{x.election_id}, '#{x.district_id}', '#{x.precinct_id}')"}.uniq.join(", ")
    client.execute(sql)


    # mark crowd datum as invalid
    puts "marking crowd data as invalid"
    sql = "update crowd_data as cd inner join has_protocols as hp on
          hp.election_id = cd.election_id and hp.district_id = cd.district_id and hp.precinct_id = cd.precinct_id
          set cd.is_valid = 0, cd.updated_at = '#{now}' where cd.is_valid = 1"
    client.execute(sql)

    # delete analysis record
    puts "removing analysis records"
    sql = "delete p from `protocol_analysis`.`#{major.analysis_table_name} - raw` as p
            inner join has_protocols as hp on
            hp.district_id = p.district_id COLLATE utf8_unicode_ci
            and hp.precinct_id = p.precinct_id COLLATE utf8_unicode_ci
            where hp.election_id = #{major.id}"
    client.execute(sql)

  end

  def down
    puts "do nothing"
  end
end
