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
      stats[:protocols_not_entered][:number] = format_number(data[:num_protocols_not_entered])
      stats[:protocols_not_entered][:percent] = format_percent(100*data[:num_protocols_not_entered]/data[:num_protocols_found].to_f)
      stats[:protocols_validated] = Hash.new
      stats[:protocols_validated][:number] = format_number(data[:num_protocols_validated])
      stats[:protocols_validated][:percent] = format_percent(100*data[:num_protocols_validated]/data[:num_protocols_found].to_f)
    end    
    return stats
  end

  #######################
  #######################

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
              precinct['found'] = false
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



  protected 
  
  
  def self.format_number(number)
    ActionController::Base.helpers.number_with_delimiter(ActionController::Base.helpers.number_with_precision(number))
  end

  def self.format_percent(number)
    ActionController::Base.helpers.number_to_percentage(ActionController::Base.helpers.number_with_precision(number))
  end

end
