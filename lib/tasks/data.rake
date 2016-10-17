namespace :data do
  ##############################
  desc "remove duplicate records in all analysis raw tables"
  task :remove_duplicate_records => [:environment] do

    client = ActiveRecord::Base.connection

    table_names = Election.where(['election_at <= ?', Time.now.to_date]).pluck(:analysis_table_name)

    if table_names.present?
      table_names.each do |table_name|
        puts table_name

        sql = "ALTER TABLE `protocol_analysis`.`#{table_name} - raw` ADD id INT PRIMARY KEY AUTO_INCREMENT;"
        client.execute(sql)

        sql = "delete a from `protocol_analysis`.`#{table_name} - raw` as a, `protocol_analysis`.`#{table_name} - raw` as b
                where a.district_id = b.district_id  and a.precinct_id = b.precinct_id and a.id < b.id"
        client.execute(sql)

        sql = "ALTER TABLE `protocol_analysis`.`#{table_name} - raw` drop column id;"
        client.execute(sql)

      end
    end
  end

end
