class AddAmendmentFields < ActiveRecord::Migration
  def up
    client = ActiveRecord::Base.connection

    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - raw` ADD `amendments_flag` INT(11) NULL DEFAULT NULL after more_votes_than_ballots"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - raw` ADD `amendment_count` INT(11) NULL DEFAULT NULL after amendments_flag"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` ADD `amendments_flag` INT(11) NULL DEFAULT NULL after more_votes_than_ballots"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` ADD `amendment_count` INT(11) NULL DEFAULT NULL after amendments_flag"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` ADD `amendments_flag` INT(11) NULL DEFAULT NULL after more_votes_than_ballots"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` ADD `amendment_count` INT(11) NULL DEFAULT NULL after amendments_flag"
    client.execute(sql)

    # move amendment data from districtprecinct to raw tables
    prop = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Party List'}).first
    major = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Majoritarian'}).first

    sql = "update `protocol_analysis`.`2016_parliamentary_party_list - raw` as raw
          inner join district_precincts as dp on
            dp.district_id = raw.district_id COLLATE utf8_unicode_ci
            and dp.precinct_id = raw.precinct_id COLLATE utf8_unicode_ci
          set raw.amendments_flag = dp.has_amendment,
              raw.amendment_count = dp.amendment_count
          where dp.election_id = #{prop.id}"
    client.execute(sql)

    sql = "update `protocol_analysis`.`2016_parliamentary_majoritarian - raw` as raw
          inner join district_precincts as dp on
            dp.district_id = raw.district_id COLLATE utf8_unicode_ci
            and dp.precinct_id = raw.precinct_id COLLATE utf8_unicode_ci
          set raw.amendments_flag = dp.has_amendment,
              raw.amendment_count = dp.amendment_count
          where dp.election_id = #{major.id}"
    client.execute(sql)

    # recreate the views to work with the amendment fields
    prop.create_analysis_views
    major.create_analysis_views


  end

  def down
    client = ActiveRecord::Base.connection

    # recreate the views to work without the amendment fields
    prop = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Party List'}).first
    major = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Majoritarian'}).first
    prop.create_analysis_views
    major.create_analysis_views


    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - raw` drop column `amendments_flag`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - raw` drop column `amendment_count`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` drop column `amendments_flag`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` drop column `amendment_count`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` drop column `amendments_flag`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` drop column `amendment_count`"
    client.execute(sql)


  end
end
