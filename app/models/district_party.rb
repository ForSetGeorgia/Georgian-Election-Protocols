class DistrictParty < ActiveRecord::Base
  #######################################
  ## RELATIONSHIPS
  belongs_to :election
  belongs_to :party

  #######################################
  ## ATTRIBUTES
  attr_accessible :district_id, :election_id, :party_id

  #######################################
  ## VALIDATIONS
  validates :district_id, :election_id, :party_id, :presence => true
  validates :party_id, uniquness: { scope: [:election_id, :district_id]}

  #######################################
  ## SCOPES
  scope :sorted, with_translations(I18n.locale).order("election_translations.name asc")

end
