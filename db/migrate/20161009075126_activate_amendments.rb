class ActivateAmendments < ActiveRecord::Migration
  def up
    client = ActiveRecord::Base.connection
    now = Time.now

    # get list of elections/districts/precincts that have amendments
    path = "#{Rails.root}/public/system/protocols/**/*_amendment_*.jpg"
    amendments = Dir.glob(path)

    if amendments.present?
      puts "there are #{amendments.length} amendments"
      # pull out the ids
      ids = []
      # the path is in the following format:
      # "#{Rails.root}/public/system/protocols/#{election_id}/#{district_id}/#{district_id}-#{precinct_id}_amendment_*.jpg
      amendments.each do |file|
        file_parts = file.split('/')
        h = Hash.new
        h[:election_id] = file_parts[-3]
        h[:district_id] = file_parts[-2]
        h[:precinct_id] = file_parts[-1].gsub(/\d*-(\d*.\d*)_amendment_\d*.jpg/, '\1')
        ids << h
      end

      # there may be duplicates due to having multiple protocols
      ids.uniq!

      puts "records that have protocols"
      puts ids

      HasProtocol.delete_all

      # load all districts/precincts that have amendment
      puts 'loading ids into temp table'
      sql = "insert into has_protocols (election_id, district_id, precinct_id) values "
      sql << ids.map{|x| "(#{x[:election_id]}, '#{x[:district_id]}', '#{x[:precinct_id]}')"}.uniq.join(", ")
      client.execute(sql)

      # mark flag
      puts 'indicating that these records have amendments'
      sql = "update district_precincts as dp inner join has_protocols as hp on
              hp.election_id = dp.election_id and hp.district_id = dp.district_id and hp.precinct_id = dp.precinct_id
              set dp.has_amendment = 1, dp.is_validated = 0, dp.updated_at = '#{now}' "
      client.execute(sql)

      # mark crowd datum as invalid
      puts "marking crowd data as invalid"
      sql = "update crowd_data as cd inner join has_protocols as hp on
            hp.election_id = cd.election_id and hp.district_id = cd.district_id and hp.precinct_id = cd.precinct_id
            set cd.is_valid = 0, cd.updated_at = '#{now}' where cd.is_valid = 1"
      client.execute(sql)

      # delete analysis record
      puts "removing analysis records"
      elections = Election.where(id: ids.map{|x| x['election_id']}).uniq
      if elections.present?
        elections.each do |election|
          sql = "delete p from `#{@@analysis_db}`.`#{election.analysis_table_name} - raw` as p
                  inner join has_protocols as hp on hp.election_id = p.election_id and hp.district_id = p.district_id and hp.precinct_id = p.precinct_id "
          client.execute(sql)
        end
      end


    end
  end

  def down
    puts "do nothing"
  end
end
