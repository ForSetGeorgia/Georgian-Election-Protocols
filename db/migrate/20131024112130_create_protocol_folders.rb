class CreateProtocolFolders < ActiveRecord::Migration
	require 'fileutils'
  def up
    path = "#{Rails.root}/public/system/protocols/"
    
    districts = DistrictPrecinct.select('distinct district_id')
    
    if districts.present?
      districts.map{|x| x.district_id}.each do |district_id|
        file_path = path + district_id.to_s
		    FileUtils.mkpath(file_path)
      end
    end
  end

  def down
    # do nothing
    
  end
end
