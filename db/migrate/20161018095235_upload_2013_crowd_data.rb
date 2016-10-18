class Upload2013CrowdData < ActiveRecord::Migration
  def up
    # these 2013 presidential crowd_data records were accidentally deleted on election day of 2016
    # due to little sleep
    # reloading the data from a backup of the table

    require 'csv'
    client = ActiveRecord::Base.connection
    file = "#{Rails.root}/db/data/2013/2013_crowd_data.csv"

    if File.exists? file
      data = CSV.read(file, headers: true)

      sql_template = "insert into crowd_data ("
      sql_template << data.headers.join(',')
      sql_template << ") values "

      rows = []
      data.each_with_index do |row, index|
        rows << "(" + row.to_a.map{|x| "'#{x[1]}'"}.join(', ') + ")"

        if index > 0 && (index % 1000 == 0 || index == data.length-1)
          puts "- index = #{index}, inserting data"
          sql = sql_template.dup
          sql << rows.join(', ')
          client.execute sql

          rows = []
        end
      end

    end

  end

  def down
    election = Election.includes(:election_translations).where(election_translations: {name: '2013 Presidential'}).first
    puts "deleting all crowd data for 2013 election"
    CrowdData.where(election_id: election.id).delete_all
  end
end
