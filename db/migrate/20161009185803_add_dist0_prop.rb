class AddDist0Prop < ActiveRecord::Migration
  def up
    client = ActiveRecord::Base.connection
    now = Time.now
    csv_path = "#{Rails.root}/db/data/2016/"

    election = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Party List'}).first

    puts '- assign precincts/districts'
    csv_data = CSV.read(csv_path + '2016_district0_precincts.csv')
    sql_values = []
    csv_data.each_with_index do |row, i|
      if i > 0
        sql_values << "(#{election.id}, '#{row[0]}', '#{row[1]}', '#{now}')"
      end
    end
    client.execute("insert into district_precincts
      (`election_id`, `district_id`, `precinct_id`, `created_at`)
      values #{sql_values.join(', ')}"
    )
  end

  def down
    puts 'do nothing'
  end
end
