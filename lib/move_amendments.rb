require 'net/scp'

module MoveAmendments

  def self.pull_from_prod(password)
    Net::SCP.start("epsilon.jumpstart.ge", "protocols", :password => password ) do |scp|
      dps = DistrictPrecinct.where(:has_amendment => true)

      if dps.present?
        puts "dps length = #{dps.length}"
        dps.each do |dp|
          puts "district id = #{dp.district_id}; precinct id = #{dp.precinct_id}"
          scp.download!("/home/protocols/Protocols/shared/system/protocols/#{dp.district_id}/#{dp.district_id}-#{dp.precinct_id}-amended.jpg", 
            "#{Rails.root}/public/system/protocols/#{dp.district_id}/")
        end
      end

    end
  end
  
end

