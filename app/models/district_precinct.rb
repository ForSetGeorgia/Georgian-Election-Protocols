class DistrictPrecinct < ActiveRecord::Base

  #######################################
  ## ATTRIBUTES
  attr_accessible :election_id, :district_id, :precinct_id, :has_protocol, :is_validated, :has_amendment
  attr_accessor :num_precincts, :num_protocols_found, :num_protocols_missing, :num_protocols_not_entered, :num_protocols_validated

  #######################################
  ## VALIDATIONS
  validates :election_id, :district_id, :precinct_id, :presence => true

  #######################################
  ## SCOPES
  def self.by_election(election_id)
    where(election_id: election_id)
  end

  def self.by_ids(election_id, district_id, precinct_id)
    where(election_id: election_id, district_id: district_id, precinct_id: precinct_id)
  end

  def self.with_protocols
    where(:has_protocol => true).order("election_id, district_id, precinct_id")
  end

  def self.awaiting_protocols
    where(:has_protocol => false).order("election_id, district_id, precinct_id")
  end

  def self.district_count_by_election(election_id)
    select('distinct district_id').by_election(election_id).count
  end

  #######################
  # flag descriptions
  #######################
  # has_protocol
  # - 0 = default value
  # - 1 = set to true when scrapper indicates that it found the protocol

  # is_validated
  # - 0 = default value
  # - 1 = set to true two crowd datum records have matched and the data has been moved to raw table

  #######################


  #######################
  #######################

  # assign region name to records for election
  def self.assign_region_name(election_id)
    region_districts = RegionDistrictName.sorted
    if region_districts.present?
      regions = region_districts.map{|x| x.region}.uniq

      regions.each do |region|
        district_ids = region_districts.select{|x| x.region == region}.map{|x| x.district_id}.uniq
        DistrictPrecinct.where(election_id: election_id, district_id: district_ids).update_all(region: region)
      end
    end
  end

  # creates array of districts/precincts that have protocols
  #format: [ {election_id => a, districts => [ { district_id => [ precinct_id, precinct_id,   ] } ] } ]
  def self.found_protocols
    # records = []
    elections = Election.can_enter
    records = with_protocols.by_election(elections.map{|x| x.id})

    return build_api_request(elections, records)
  end


  # creates array of districts/precincts that are missing protocols
  #format: [ {election_id => a, districts => [ { district_id => [ precinct_id, precinct_id,   ] } ] } ]
  def self.missing_protocols
    # records = []
    elections = Election.can_enter
    records = awaiting_protocols.by_election(elections.map{|x| x.id})

    return build_api_request(elections, records)
  end


  # for each precinct in a district, if it is marked as found, update the table record
  def self.mark_found_protocols(json)
    success = true

    if json.present?
      DistrictPrecinct.transaction do
        json.each do |district|
          if district.has_key?('district_id') && district['district_id'].present? &&
              district.has_key?('precincts') && district['precincts'].present?

            district['precincts'].each do |precinct|
              if precinct.has_key?('id') && precinct['id'].present? &&
                  precinct.has_key?('found') && precinct['found'].present? &&
                  (precinct['found'] == true || precinct['found'] == 'true')

                # found district/precinct that has a protocol
                # - update the record
                u = DistrictPrecinct.where(:district_id => district['district_id'], :precinct_id => precinct['id'])
                  .update_all(:has_protocol => true)

                if u == 0
                  success = false
	                raise ActiveRecord::Rollback
                  return success
                end

              end
            end
          end
        end
      end
    end

    return success
  end


  #######################
  ## stats
  #######################

  # get the following:
  # total districts (#), total precincts (#), protocols found (#/%), protocols missing (#/%), protocols not entered (#/%), protocols validated (#/%)
  def self.overall_stats(election_ids)
    election_stats = []

    election_ids = [election_ids] if election_ids.class.name == 'Fixnum'

    # only continue if there are elections running
    if election_ids.present?
      election_ids.each do |election_id|
        dist_count = self.district_count_by_election(election_id)

        sql = "select count(*) as num_precincts, sum(has_protocol) as num_protocols_found, (count(*) - sum(has_protocol)) as num_protocols_missing, "
        sql << "sum(if(has_protocol = 1 and is_validated = 0, 1, 0)) as num_protocols_not_entered, sum(if(has_protocol = 1 and is_validated = 1, 1, 0)) as num_protocols_validated "
        sql << "from district_precincts where election_id = ?"

        data = find_by_sql([sql, election_id])

        if data.present?
          data = data.first
          stats = Hash.new
          stats[:election_id] = election_id
          stats[:districts] = format_number(dist_count)
          stats[:precincts] = format_number(data[:num_precincts])
          stats[:protocols_missing] = Hash.new
          stats[:protocols_missing][:number] = format_number(data[:num_protocols_missing])
          stats[:protocols_missing][:percent] = format_percent(100*data[:num_protocols_missing]/data[:num_precincts].to_f)
          stats[:protocols_found] = Hash.new
          stats[:protocols_found][:number] = format_number(data[:num_protocols_found])
          stats[:protocols_found][:percent] = format_percent(100*data[:num_protocols_found]/data[:num_precincts].to_f)
          stats[:protocols_not_entered] = Hash.new
          stats[:protocols_not_entered][:number] = data[:num_protocols_found] > 0 ? format_number(data[:num_protocols_not_entered]) : I18n.t('app.common.na')
          stats[:protocols_not_entered][:percent] = data[:num_protocols_found] > 0 ? format_percent(100*data[:num_protocols_not_entered]/data[:num_protocols_found].to_f) : I18n.t('app.common.na')
          stats[:protocols_validated] = Hash.new
          stats[:protocols_validated][:number] = data[:num_protocols_found] > 0 ? format_number(data[:num_protocols_validated]) : I18n.t('app.common.na')
          stats[:protocols_validated][:percent] = data[:num_protocols_found] > 0 ? format_percent(100*data[:num_protocols_validated]/data[:num_protocols_found].to_f) : I18n.t('app.common.na')

          election_stats << stats
        end
      end
    end

    return election_stats
  end


  # get the following:
  # district id/name, total precincts (#), protocols found (#/%), protocols missing (#/%), protocols not entered (#/%), protocols validated (#/%)
  def self.overall_stats_by_district(election_ids)
    election_stats = []

    election_ids = [election_ids] if election_ids.class.name == 'Fixnum'

    # only continue if there are elections running
    if election_ids.present?
      election_ids.each do |election_id|

        election = Election.where(id: election_id).first

        if election.has_regions || election.has_district_names
          regions = RegionDistrictName.sorted
        end

        sql = "select district_id, count(*) as num_precincts, sum(has_protocol) as num_protocols_found, (count(*) - sum(has_protocol)) as num_protocols_missing, "
        sql << "sum(if(has_protocol = 1 and is_validated = 0, 1, 0)) as num_protocols_not_entered, sum(if(has_protocol = 1 and is_validated = 1, 1, 0)) as num_protocols_validated "
        sql << "from district_precincts where election_id = ? group by district_id order by district_id"

        data = find_by_sql([sql, election_id])

        if data.present?
          stats = Hash.new
          stats[:election_id] = election_id
          stats[:districts] = []
          data.each do |district|
            district_stats = Hash.new
            stats[:districts] << district_stats

            if regions.present?
              region = regions.select{|x| x.district_id == district[:district_id]}.first
              if region.present?
                district_stats[:region] = region.region
                district_stats[:district] = region.district_name
              end
            end
            district_stats[:district_id] = district[:district_id]
            district_stats[:precincts] = format_number(district[:num_precincts])
            district_stats[:protocols_missing] = Hash.new
            district_stats[:protocols_missing][:number] = format_number(district[:num_protocols_missing])
            district_stats[:protocols_missing][:percent] = format_percent(100*district[:num_protocols_missing]/district[:num_precincts].to_f)
            district_stats[:protocols_found] = Hash.new
            district_stats[:protocols_found][:number] = format_number(district[:num_protocols_found])
            district_stats[:protocols_found][:percent] = format_percent(100*district[:num_protocols_found]/district[:num_precincts].to_f)
            district_stats[:protocols_not_entered] = Hash.new
            district_stats[:protocols_not_entered][:number] = district[:num_protocols_found] > 0 ? format_number(district[:num_protocols_not_entered]) : I18n.t('app.common.na')
            district_stats[:protocols_not_entered][:percent] = district[:num_protocols_found] > 0 ? format_percent(100*district[:num_protocols_not_entered]/district[:num_protocols_found].to_f) : I18n.t('app.common.na')
            district_stats[:protocols_validated] = Hash.new
            district_stats[:protocols_validated][:number] = district[:num_protocols_found] > 0 ? format_number(district[:num_protocols_validated]) : I18n.t('app.common.na')
            district_stats[:protocols_validated][:percent] = district[:num_protocols_found] > 0 ? format_percent(100*district[:num_protocols_validated]/district[:num_protocols_found].to_f) : I18n.t('app.common.na')
          end

          election_stats << stats
        end
      end
    end
    return election_stats
  end


  ############################################
  ############################################
  def self.new_image_search
    files = Dir.glob("#{Rails.root}/public/system/protocols/**/*.jpg")
    if files.present?
      ids = files.map{|x| x.split('/').last.gsub('.jpg', '').split('-')}
      if ids.present?
        DistrictPrecinct.transaction do
          # remove anything that was there
          HasProtocol.delete_all

          puts "++++++++++ image count = #{ids.length}"

          # load all districts/precincts that exist
          sql = "insert into has_protocols (district_id, precinct_id) values "
          sql << ids.map{|x| "(#{x[0]}, #{x[1]})"}.uniq.join(", ")
          ActiveRecord::Base.connection.execute(sql)

          # update district precint table to mark these as existing
          now = Time.now
          sql = "update district_precincts as dp left join has_protocols as hp on hp.district_id = dp.district_id and hp.precinct_id = dp.precinct_id "
          sql << "set dp.has_protocol = if(hp.id is null, 0, 1), dp.updated_at = '#{now}' "
          ActiveRecord::Base.connection.execute(sql)

          # if an amendment has been found for a protocol that has already been entered, the protocol needs to be re-entered
          # -> mark the crowd data records as invalid and delete the pres2013 record.
          HasProtocol.delete_all

          puts "++++++++++ image's with amendment count = #{ids.select{|x| x.length == 3}.length}"

          # load all districts/precincts that have amendment
          sql = "insert into has_protocols (district_id, precinct_id) values "
          sql << ids.select{|x| x.length == 3}.map{|x| "(#{x[0]}, #{x[1]})"}.uniq.join(", ")
          ActiveRecord::Base.connection.execute(sql)

          # if district/precinct did not have amendment:
          # - update flag
          # - mark crowd datum as invalid
          # - delete pres2013
          sql = "select dp.district_id, dp.precinct_id from district_precincts as dp "
          sql << "inner join has_protocols as hp on hp.district_id = dp.district_id and hp.precinct_id = dp.precinct_id "
          sql << "where dp.has_amendment = 0"
          precincts = ActiveRecord::Base.connection.select_all(sql)
          puts "++++++++++ found #{precincts.present? ? precincts.length : 0} new amendments"

          if precincts.present?
            # clear out temp table
            HasProtocol.delete_all

            # insert the records that have no protocols
            sql = "insert into has_protocols (district_id, precinct_id) values "
            sql << precincts.map{|x| "(#{x['district_id']}, #{x['precinct_id']})"}.uniq.join(", ")
            ActiveRecord::Base.connection.execute(sql)

            # mark flag
            sql = "update district_precincts as dp inner join has_protocols as hp on hp.district_id = dp.district_id and hp.precinct_id = dp.precinct_id "
            sql << "set dp.has_amendment = 1, dp.is_validated = 0, dp.updated_at = '#{now}' "
            ActiveRecord::Base.connection.execute(sql)

            # mark crowd datum as invalid
            sql = "update crowd_data as cd inner join has_protocols as hp on hp.district_id = cd.district_id and hp.precinct_id = cd.precinct_id "
            sql << "set cd.is_valid = 0, cd.updated_at = '#{now}' where cd.is_valid = 1"
            ActiveRecord::Base.connection.execute(sql)

            # delete pres record
            sql = "delete p from president2013s as p inner join has_protocols as hp on hp.district_id = p.district_id and hp.precinct_id = p.precinct_id "
            ActiveRecord::Base.connection.execute(sql)
          end

        end
      end
    end
  end

  protected


  def self.format_number(number)
    ActionController::Base.helpers.number_with_delimiter(ActionController::Base.helpers.number_with_precision(number))
  end

  def self.format_percent(number)
    ActionController::Base.helpers.number_to_percentage(ActionController::Base.helpers.number_with_precision(number))
  end


  #format: [ {election_id => a, districts => [ { district_id => [ precinct_id, precinct_id,   ] } ] } ]
  def self.build_api_request(elections, data)
    records = []
    if elections.present? && data.present?
      elections.each do |election|
        e = {
          election_id: election.id,
          scraper_url_base: election.scraper_url_base,
          scraper_url_folder_to_images: election.scraper_url_folder_to_images,
          scraper_page_pattern: election.scraper_page_pattern,
          districts: []
        }

        records << e

        district_ids = data.select{|x| x.election_id == election.id}.map{|x| x.district_id}.uniq

        if district_ids.present?
          district_ids.each do |district_id|
            district = Hash.new
            e[:districts] << district
            district[district_id] = []
            precinct_ids = data.select{|x| x.election_id == election.id && x.district_id == district_id}.map{|x| x.precinct_id}.uniq.sort

            if precinct_ids.present?
              district[district_id] << precinct_ids
            end

          end
        end
      end
    end

    return records
  end

end
