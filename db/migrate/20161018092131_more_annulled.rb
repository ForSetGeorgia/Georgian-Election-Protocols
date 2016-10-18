class MoreAnnulled < ActiveRecord::Migration
  def up
    client = ActiveRecord::Base.connection

    prop = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Party List'}).first
    major = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Majoritarian'}).first

    # for some reason these precincts do not exist in precinct list, so add it
    DistrictPrecinct.create(election_id: prop.id, district_id: '66', precinct_id: '67.79')
    DistrictPrecinct.create(election_id: prop.id, district_id: '66', precinct_id: '67.108')
    DistrictPrecinct.create(election_id: major.id, district_id: '66', precinct_id: '67.79')
    DistrictPrecinct.create(election_id: major.id, district_id: '66', precinct_id: '67.108')

    # flag the following precicnts that are annulled for both party list and major
    annulled = [
      {district_id: '15', precinct_id: '08.14'},
      {district_id: '15', precinct_id: '08.26'},
      {district_id: '34', precinct_id: '24.08'},
      {district_id: '34', precinct_id: '24.14'},
      {district_id: '35', precinct_id: '22.34'},
      {district_id: '36', precinct_id: '22.48'},
      {district_id: '66', precinct_id: '67.38'},
      {district_id: '66', precinct_id: '67.79'},
      {district_id: '66', precinct_id: '67.108'}

    ]

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

    # fix the precinct count since we added precincts
    prop.create_analysis_precinct_counts
    major.create_analysis_precinct_counts

  end

  def down
    client = ActiveRecord::Base.connection

    prop = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Party List'}).first
    major = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Majoritarian'}).first

    # for some reason these precincts do not exist in precinct list, so add it
    DistrictPrecinct.where(election_id: prop.id, district_id: '66', precinct_id: '67.79').delete_all
    DistrictPrecinct.where(election_id: prop.id, district_id: '66', precinct_id: '67.108').delete_all
    DistrictPrecinct.where(election_id: major.id, district_id: '66', precinct_id: '67.79').delete_all
    DistrictPrecinct.where(election_id: major.id, district_id: '66', precinct_id: '67.108').delete_all

    sql = "delete from `protocol_analysis`.`2016_parliamentary_party_list - raw`
            where district_id = '66' and precinct_id = '67.79'"
    client.execute(sql)
    sql = "delete from `protocol_analysis`.`2016_parliamentary_party_list - raw`
            where district_id = '66' and precinct_id = '67.108'"
    client.execute(sql)

    sql = "delete from `protocol_analysis`.`2016_parliamentary_majoritarian - raw`
            where district_id = '66' and precinct_id = '67.79'"
    client.execute(sql)
    sql = "delete from `protocol_analysis`.`2016_parliamentary_majoritarian - raw`
            where district_id = '66' and precinct_id = '67.108'"
    client.execute(sql)

    # fix the precinct count since we deleted precincts
    prop.create_analysis_precinct_counts
    major.create_analysis_precinct_counts
  end
end
