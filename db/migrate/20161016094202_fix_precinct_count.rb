class FixPrecinctCount < ActiveRecord::Migration
  def up
    client = ActiveRecord::Base.connection

    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - precinct count` drop index `district`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - precinct count` modify `district_id` varchar(10) NOT NULL"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - precinct count` add index `district` (`district_id`)"
    client.execute(sql)

    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - precinct count` drop index `district`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - precinct count` modify `district_id` varchar(10) NOT NULL"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - precinct count` add index `district` (`district_id`)"
    client.execute(sql)

    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - precinct count` drop index `district`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - precinct count` modify `district_id` varchar(10) NOT NULL"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - precinct count` add index `district` (`district_id`)"
    client.execute(sql)

    # re-load the precinct counts
    pres = Election.includes(:election_translations).where(election_translations: {name: '2013 Presidential'}).first
    prop = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Party List'}).first
    major = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Majoritarian'}).first

    pres.load_analysis_precinct_counts
    prop.load_analysis_precinct_counts
    major.load_analysis_precinct_counts
  end

  def down
    puts "do nothing"
  end
end
