class DistrictParty < ActiveRecord::Base
  #######################################
  ## RELATIONSHIPS
  belongs_to :election

  #######################################
  ## ATTRIBUTES
  attr_accessible :district_id, :election_id, :party_id

  #######################################
  ## VALIDATIONS
  validates :district_id, :election_id, :party_id, :presence => true
  validates :party_id, uniqueness: { scope: [:election_id, :district_id]}

  #######################################
  ## SCOPES

  def self.by_election_district(election_id, district_id)
    where(election_id: election_id, district_id: district_id)
  end

end
