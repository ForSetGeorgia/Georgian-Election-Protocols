class Election < ActiveRecord::Base
  #######################################
  ## TRANSLATIONS
  translates :name

  #######################################
  ## RELATIONSHIPS
  has_many :parties, :dependent => :destroy
  has_many :election_translations, :dependent => :destroy
  accepts_nested_attributes_for :election_translations

  #######################################
  ## ATTRIBUTES
  attr_accessible :can_enter_data, :election_app_event_id, :election_at, :election_translations_attributes

  #######################################
  ## VALIDATIONS
  validates :election_at, :presence => true
  validates :election_app_event_id, :presence => true, if: 'can_enter_data == true'

  #######################################
  ## SCOPES
  def self.by_election(election_id)
    where(election_id: election_id)
  end

  def self.by_election_district(election_id, district_id)
    by_election(election_id).where(district_id: district_id)
  end

end
