class FixAmendments < ActiveRecord::Migration
  def up
    DistrictPrecinct.transaction do
      records_fixed = 0
      # mark everything with amendment as not validated
      dps = DistrictPrecinct.where(:has_amendment => true, :is_validated => false)
      
      if dps.present?
        # for each district/precinct see if crowd data exists
        # if so, if there are matches, mark them as valid
        dps.each do |dp|
          puts "district #{dp.district_id}; precinct #{dp.precinct_id}"
          matches = []
          crowds = CrowdDatum.where(["is_valid = 0 and district_id = ? and precinct_id = ? and created_at > ?", dp.district_id, dp.precinct_id, '2013-10-29'])
          if crowds.present?
            (0..crowds.length-1).each do |i|
              (0..crowds.length-1).each do |j|
                if i != j
                  if crowds[i].attributes.except('id', 'created_at', 'updated_at', 'user_id', 'is_valid', 'is_extra') == crowds[j].attributes.except('id', 'created_at', 'updated_at', 'user_id', 'is_valid', 'is_extra')
#                    puts "- crowd id #{crowds[i].id} = #{crowds[j].id}"
                    if matches.blank?
                      # create new array
                      x = [crowds[i].id, crowds[j].id]
                      matches << x
                    else
                      # see if this pair already exists
                      indexi = matches.index{|x| x.include?(crowds[i].id)}
                      indexj = matches.index{|x| x.include?(crowds[j].id)}
                      
                      if indexi.present? && indexj.present? && indexi == indexj
                        # already found
                      elsif indexi.present? && indexj.present? && indexi != indexj
                        # what do here?
                        
                      elsif indexi.present? && indexj.blank?
                        matches[indexi] << crowds[j].id
                      elsif indexi.blank? && indexj.present?
                        matches[indexj] << crowds[i].id
                      else
                        x = [crowds[i].id, crowds[j].id]
                        matches << x
                      end
                    end
                  end
                end
              end
            end
          end
          puts "- matched length = #{matches.length}; crowd ids = #{matches}"
          
          # if matched length = 1, mark those as valid
          # - if there are more than 1 sets of matches, cannot mark as valid for do not know which is valid
          if matches.length == 1
            puts "-- marking as valid!"
            crowd = crowds.select{|x| x.id == matches.first.first}
            if crowd.present?
              record = crowd.first
            
              record.match_and_validate
              
              records_fixed += 1
            end
          
          end
        end
      end

      puts "out of #{dps.length} district/precincts, made #{records_fixed} districts/precincts valid"
    end
    
  end

  def down
=begin
    DistrictPrecinct.transaciton do

      # mark everything with amendment as not validated
      dps = DistrictPrecincts.where(:has_amendments => true)
      
      if dps.present?
        HasProtocol.delete_all

        # load all districts/precincts that exist
        sql = "insert into has_protocols (district_id, precinct_id) values "
        sql << dps.map{|x| "(#{x.district_id}, #{x.precinct_id})"}.uniq.join(", ")
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
=end    
  end
end
