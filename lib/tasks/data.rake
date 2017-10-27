namespace :data do
  ##############################
  desc "remove duplicate records in all analysis raw tables"
  task :remove_duplicate_records => [:environment] do

    client = ActiveRecord::Base.connection

    elections = Election.can_enter

    if elections.present?
      elections.each do |election|
        table_name = election.analysis_table_name

        puts "#{table_name} had #{election.completed_precinct_count} precincts"

        sql = "ALTER TABLE `protocol_analysis`.`#{table_name} - raw` ADD id INT PRIMARY KEY AUTO_INCREMENT;"
        client.execute(sql)

        sql = "delete a from `protocol_analysis`.`#{table_name} - raw` as a, `protocol_analysis`.`#{table_name} - raw` as b
                where a.district_id = b.district_id  and a.precinct_id = b.precinct_id and a.id < b.id"
        client.execute(sql)

        sql = "ALTER TABLE `protocol_analysis`.`#{table_name} - raw` drop column id;"
        client.execute(sql)

        puts "#{table_name} now has #{election.completed_precinct_count} precincts"

      end
    end
  end

end
