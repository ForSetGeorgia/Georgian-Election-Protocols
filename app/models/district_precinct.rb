class DistrictPrecinct < ActiveRecord::Base

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

end
