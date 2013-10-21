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
end
