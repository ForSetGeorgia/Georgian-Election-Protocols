class FixAnalysisRawDuplicates < ActiveRecord::Migration
  def up
    client = ActiveRecord::Base.connection

    # in order to delete the duplicate records, an id column needs to be addded first
    puts 'adding id column'
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` ADD id INT PRIMARY KEY AUTO_INCREMENT;"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` ADD id INT PRIMARY KEY AUTO_INCREMENT;"
    client.execute(sql)

    # delete the first duplicate
    sql = "delete a from `protocol_analysis`.`2016_parliamentary_party_list - raw` as a, `protocol_analysis`.`2016_parliamentary_party_list - raw` as b
            where a.district_id = b.district_id  and a.precinct_id = b.precinct_id and a.id < b.id"
    client.execute(sql)
    puts "deleted dups from party list"
    sql = "delete a from `protocol_analysis`.`2016_parliamentary_majoritarian - raw` as a, `protocol_analysis`.`2016_parliamentary_majoritarian - raw` as b
            where a.district_id = b.district_id  and a.precinct_id = b.precinct_id and a.id < b.id"
    client.execute(sql)
    puts "deleted dups from party list"

    # deleting the id columns
    puts 'deleting id column'
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` drop column id;"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` drop column id;"
    client.execute(sql)

  end

  def down
    puts "do nothing"
  end
end
