class DistrictParty < ActiveRecord::Base
  #######################################
  ## RELATIONSHIPS
  belongs_to :election

  #######################################
  ## ATTRIBUTES
  attr_accessible :district_id, :major_district_id, :election_id, :party_number

  #######################################
  ## VALIDATIONS
  validates :district_id, :election_id, :party_number, :presence => true
  validates :party_number, uniqueness: { scope: [:election_id, :district_id]}

  #######################################
  ## SCOPES

  def self.by_election_district(election_id, district_id, major_district_id=nil)
    where(election_id: election_id, district_id: district_id, major_district_id: major_district_id)
  end

  def self.max_parties_in_district(election_id, is_local_majoritarian)
    x = where(election_id: election_id)
    if is_local_majoritarian
      x = x.group(:major_district_id)
    else
      x = x.group(:district_id)
    end
    x = x.count.values.max
  end

end
