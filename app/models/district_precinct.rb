class DistrictPrecinct < ActiveRecord::Base

  attr_accessor :num_precincts, :num_protocols_found, :num_protocols_missing, :num_protocols_not_entered, :num_protocols_validated


  #######################
  # flag descriptions
  #######################
  # has_protocol
  # - 0 = default value
  # - 1 = set to true when scrapper indicates that it found the protocol
  
  # is_validated
  # - 0 = default value
  # - 1 = set to true two crowd datum records have matched and the data has been moved to pres table
  
  #######################


  #######################
  #######################

  # creates array of districts/precincts that have protocols
  #format: [ {district_id => x, precincts => [ {id => x }, ...  ] }, .... ]
  def self.found_protocols
    records = []
    x = where(:has_protocol => true).order("district_id, precinct_id")
    
    if x.present?
      district_ids = x.map{|x| x.district_id}.uniq
      if district_ids.present?
        district_ids.each do |district_id|
          district = Hash.new
          records << district
          district['district_id'] = district_id
          district['precincts'] = []
          precinct_ids = x.select{|x| x.district_id == district_id}.map{|x| x.precinct_id}.sort
          
          if precinct_ids.present?
            precinct_ids.each do |precinct_id|
              precinct = Hash.new
              district['precincts'] << precinct
              precinct['id'] = precinct_id
            end          
          end
        
        end          
      end
    end
  
    return records
  end
  
  
  # creates array of districts/precincts that are missing protocols
  #format: [ {district_id => x, precincts => [ {id => x, found => false }, ...  ] }, .... ]
  def self.missing_protocols
    records = []
    x = where(:has_protocol => false).order("district_id, precinct_id")
    
    if x.present?
      district_ids = x.map{|x| x.district_id}.uniq
      if district_ids.present?
        district_ids.each do |district_id|
          district = Hash.new
          records << district
          district['district_id'] = district_id
          district['precincts'] = []
          precinct_ids = x.select{|x| x.district_id == district_id}.map{|x| x.precinct_id}.sort
          
          if precinct_ids.present?
            precinct_ids.each do |precinct_id|
              precinct = Hash.new
              district['precincts'] << precinct
              precinct['id'] = precinct_id
#              precinct['found'] = false
            end          
          end
        
        end          
      end
    end
  
    return records
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
  def self.overall_stats
    stats = nil
    district_count = DistrictPrecinct.select('distinct district_id').count
    
    sql = "select count(*) as num_precincts, sum(has_protocol) as num_protocols_found, (count(*) - sum(has_protocol)) as num_protocols_missing, "
    sql << "sum(if(has_protocol = 1 and is_validated = 0, 1, 0)) as num_protocols_not_entered, sum(if(has_protocol = 1 and is_validated = 1, 1, 0)) as num_protocols_validated "
    sql << "from district_precincts "

    data = find_by_sql(sql)
    
    if data.present?
      data = data.first
      stats = Hash.new
      stats[:districts] = format_number(district_count)
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
    end    
    return stats
  end


  # get the following:
  # district id/name, total precincts (#), protocols found (#/%), protocols missing (#/%), protocols not entered (#/%), protocols validated (#/%) 
  def self.overall_stats_by_district
    districts = []

    names = RegionDistrictName.all    
    
    sql = "select district_id, count(*) as num_precincts, sum(has_protocol) as num_protocols_found, (count(*) - sum(has_protocol)) as num_protocols_missing, "
    sql << "sum(if(has_protocol = 1 and is_validated = 0, 1, 0)) as num_protocols_not_entered, sum(if(has_protocol = 1 and is_validated = 1, 1, 0)) as num_protocols_validated "
    sql << "from district_precincts group by district_id order by district_id"

    data = find_by_sql(sql)
    
    if data.present?
      data.each do |district|
        stats = Hash.new
        districts << stats

        index = names.index{|x| x.district_id == district[:district_id]}
        
        stats[:region] = index.present? ? names[index].region : nil
        stats[:district] = index.present? ? names[index].district_name : nil
        stats[:district_id] = district[:district_id]
        stats[:district_id] = district[:district_id]
        stats[:precincts] = format_number(district[:num_precincts])
        stats[:protocols_missing] = Hash.new
        stats[:protocols_missing][:number] = format_number(district[:num_protocols_missing])
        stats[:protocols_missing][:percent] = format_percent(100*district[:num_protocols_missing]/district[:num_precincts].to_f)
        stats[:protocols_found] = Hash.new
        stats[:protocols_found][:number] = format_number(district[:num_protocols_found])
        stats[:protocols_found][:percent] = format_percent(100*district[:num_protocols_found]/district[:num_precincts].to_f)
        stats[:protocols_not_entered] = Hash.new
        stats[:protocols_not_entered][:number] = district[:num_protocols_found] > 0 ? format_number(district[:num_protocols_not_entered]) : I18n.t('app.common.na')
        stats[:protocols_not_entered][:percent] = district[:num_protocols_found] > 0 ? format_percent(100*district[:num_protocols_not_entered]/district[:num_protocols_found].to_f) : I18n.t('app.common.na')
        stats[:protocols_validated] = Hash.new
        stats[:protocols_validated][:number] = district[:num_protocols_found] > 0 ? format_number(district[:num_protocols_validated]) : I18n.t('app.common.na')
        stats[:protocols_validated][:percent] = district[:num_protocols_found] > 0 ? format_percent(100*district[:num_protocols_validated]/district[:num_protocols_found].to_f) : I18n.t('app.common.na')
      end
    end    
    return districts
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
=begin          
          # if an amendment has been found for a protocol that has already been entered, the protocol needs to be re-entered
          # -> mark the crowd data records as invalid and delete the pres2013 record.
          HasProtocol.delete_all

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
          if precincts.present?
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
=end          
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

end
