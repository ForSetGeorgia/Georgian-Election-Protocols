class RegionDistrictName < ActiveRecord::Base

  def self.by_district(district_id)
    find_by_district_id(district_id)
  end

  def self.sorted
    order('region asc, district_id asc')
  end
end
