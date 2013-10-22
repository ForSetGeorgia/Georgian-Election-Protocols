class RegionDistrictName < ActiveRecord::Base

  def self.by_district(district_id)
    find_by_district_id(district_id)
  end
end
