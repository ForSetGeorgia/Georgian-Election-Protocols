class Party < ActiveRecord::Base
  #######################################
  ## TRANSLATIONS
  translates :name

  #######################################
  ## RELATIONSHIPS
  belongs_to :election
  has_many :party_translations, :dependent => :destroy
  accepts_nested_attributes_for :party_translations

  #######################################
  ## ATTRIBUTES
  attr_accessible :election_id, :number, :election_translations_attributes

  #######################################
  ## VALIDATIONS
  validates :election_id, :number, :presence => true

  #######################################
  ## SCOPES
  def self.by_election(election_id)
    where(election_id: election_id)
  end

  #######################################
  ## METHODS
  def self.hash_for_analysis(election_id)
    by_election(election_id).map{|x| {id: x.number, name: x.name}}
  end
end
