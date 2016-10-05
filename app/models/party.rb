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
  attr_accessible :election_id, :number, :is_independent, :election_translations_attributes

  #######################################
  ## VALIDATIONS
  validates :election_id, :number, :presence => true

  #######################################
  ## SCOPES
  def self.by_election(election_id)
    where(election_id: election_id)
  end

  def self.party_numbers
    pluck(:number)
  end

  def self.independents
    where(is_independent: true)
  end

  def self.no_independents
    where(is_independent: false)
  end

  #######################################
  ## METHODS
  def self.hash_for_analysis(election_id, include_independents=false)
    x = by_election(election_id)
    if !include_independents
      x = x.no_independents
    end
    x.map{|x| {id: x.number, name: x.name}}
  end

  def column_name
    "#{self.number} - #{self.name}"
  end
end
