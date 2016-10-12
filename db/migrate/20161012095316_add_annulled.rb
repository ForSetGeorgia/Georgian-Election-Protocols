class AddAnnulled < ActiveRecord::Migration
  def up
    client = ActiveRecord::Base.connection

    add_column :district_precincts, :is_annulled, :boolean, default: false
    add_index :district_precincts, :is_annulled

    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - raw` ADD is_annulled INT(1) NOT NULL DEFAULT 0 after more_votes_than_ballots;"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` ADD is_annulled INT(1) NOT NULL DEFAULT 0 after more_votes_than_ballots;"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` ADD is_annulled INT(1) NOT NULL DEFAULT 0 after more_votes_than_ballots;"
    client.execute(sql)


    # flag the following precicnts that are annulled for both party list and major
    annulled = [
      {district_id: '15', precinct_id: '08.14'},
      {district_id: '15', precinct_id: '08.26'},
      {district_id: '34', precinct_id: '24.08'},
      {district_id: '34', precinct_id: '24.14'},
      {district_id: '35', precinct_id: '22.34'},
      {district_id: '36', precinct_id: '22.48'}
    ]
    prop = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Party List'}).first
    major = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Majoritarian'}).first

    # for some reason 15.08.26 does not exist in precinct list, so add it
    DistrictPrecinct.create(election_id: prop.id, district_id: '15', precinct_id: '08.26')
    DistrictPrecinct.create(election_id: major.id, district_id: '15', precinct_id: '08.26')

    annulled.each do |a|
      DistrictPrecinct.where(election_id: [prop.id, major.id], district_id: a[:district_id], precinct_id: a[:precinct_id])
                        .update_all(is_annulled: true)

      sql = "update `protocol_analysis`.`2016_parliamentary_party_list - raw`
            set is_annulled = 1 where district_id = '#{a[:district_id]}' and precinct_id = '#{a[:precinct_id]}'"
      client.execute(sql)
      sql = "update `protocol_analysis`.`2016_parliamentary_majoritarian - raw`
            set is_annulled = 1 where district_id = '#{a[:district_id]}' and precinct_id = '#{a[:precinct_id]}'"
      client.execute(sql)
    end

    # recreate the views to work with the annulled field
    prop.create_analysis_views
    major.create_analysis_views

    # fix the precinct count since we added a precinct
    prop.create_analysis_precinct_counts
    major.create_analysis_precinct_counts

  end

  def down
    client = ActiveRecord::Base.connection

    remove_index :district_precincts, :is_annulled
    remove_column :district_precincts, :is_annulled

    prop = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Party List'}).first
    major = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Majoritarian'}).first

    # for some reason 15.08.26 does not exist in precinct list, so delete it
    DistrictPrecinct.where(election_id: [prop.id, major.id], district_id: '15', precinct_id: '08.26').delete_all
    sql = "delete from `protocol_analysis`.`2016_parliamentary_party_list - raw`
            where district_id = '15' and precinct_id = '08.26'"
    client.execute(sql)
    sql = "delete from `protocol_analysis`.`2016_parliamentary_majoritarian - raw`
            where district_id = '15' and precinct_id = '08.26'"
    client.execute(sql)

    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - raw` drop column is_annulled;"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` drop column is_annulled;"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` drop column is_annulled;"
    client.execute(sql)

    # fix the precinct count since we delete a precinct
    prop.create_analysis_precinct_counts
    major.create_analysis_precinct_counts


  end
end
