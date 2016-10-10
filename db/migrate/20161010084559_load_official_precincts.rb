class LoadOfficialPrecincts < ActiveRecord::Migration
  def up
    client = ActiveRecord::Base.connection
    now = Time.now
    csv_path = "#{Rails.root}/db/data/2016/"

    puts 'party list'
    election = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Party List'}).first

    puts '- getting existing districts/precincts'
    dps = DistrictPrecinct.where(election_id: election.id)

    puts '- load precincts/districts'
    csv_data = CSV.read(csv_path + '2016_official_prop_precincts.csv')
    sql_values = []
    csv_data.each_with_index do |row, i|
      if i > 0
        # if the district/precint does not exist, add it
        if dps.select{|x| x.district_id == row[0] && x.precinct_id == row[1]}.empty?
          sql_values << "(#{election.id}, '#{row[0]}', '#{row[1]}', '#{now}')"
        end
      end
    end
    puts "- adding #{sql_values.length} precincts"
    if sql_values.present?
      client.execute("insert into district_precincts
        (`election_id`, `district_id`, `precinct_id`, `created_at`)
        values #{sql_values.join(', ')}"
      )
    end

    puts "- now see if we have precincts that are not real"
    ids_to_delete = []
    dps.each do |dp|
      if csv_data.select{|row| row[0] == dp.district_id && row[1] == dp.precinct_id}.empty?
        ids_to_delete << dp.id
      end
    end
    puts "- deleting #{ids_to_delete.length} precincts for that are not real"
    DistrictPrecinct.where(id: ids_to_delete).delete_all if ids_to_delete.present?


    puts '----------------'

    puts 'major'
    election = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Majoritarian'}).first

    puts '- getting existing districts/precincts'
    dps = DistrictPrecinct.where(election_id: election.id)

    puts '- load precincts/districts'
    csv_data = CSV.read(csv_path + '2016_offical_maj_precincts.csv')
    sql_values = []
    csv_data.each_with_index do |row, i|
      if i > 0
        # if the district/precint does not exist, add it
        if dps.select{|x| x.district_id == row[0] && x.precinct_id == row[1]}.empty?
          sql_values << "(#{election.id}, '#{row[0]}', '#{row[1]}', '#{now}')"
        end
      end
    end
    puts "- adding #{sql_values.length} precincts"
    if sql_values.present?
      client.execute("insert into district_precincts
        (`election_id`, `district_id`, `precinct_id`, `created_at`)
        values #{sql_values.join(', ')}"
      )
    end

    puts "- now see if we have precincts that are not real"
    ids_to_delete = []
    dps.each do |dp|
      if csv_data.select{|row| row[0] == dp.district_id && row[1] == dp.precinct_id}.empty?
        ids_to_delete << dp.id
      end
    end
    puts "- deleting #{ids_to_delete.length} precincts for that are not real"
    DistrictPrecinct.where(id: ids_to_delete).delete_all if ids_to_delete.present?

  end

  def down
    puts 'do nothing'
  end
end
