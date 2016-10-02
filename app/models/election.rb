class Election < ActiveRecord::Base
  require 'data_analysis' # script in lib folder that has methods to create analysis tables, run them, and delete them
  include DataAnalysis

  #######################################
  ## TRANSLATIONS
  translates :name

  #######################################
  ## RELATIONSHIPS
  has_many :parties, :dependent => :destroy
  has_many :district_parties, :dependent => :destroy
  has_many :district_precincts, :dependent => :destroy
  has_many :election_translations, :dependent => :destroy
  accepts_nested_attributes_for :election_translations

  #######################################
  ## ATTRIBUTES
  attr_accessible :parties_same_for_all_districts, :can_enter_data, :is_local_majoritarian,
                  :has_regions, :has_district_names, :election_app_event_id, :election_at, :election_translations_attributes

  #######################################
  ## VALIDATIONS
  validates :election_at, :presence => true
  validates :election_app_event_id, :presence => true, if: 'can_enter_data == true'

  #######################################
  ## CALLBACKS
  before_save :set_analysis_name
  after_destroy :delete_analysis_items

  def set_analysis_name
    en_name = self.election_translations.select{|x| x.locale == 'en'}.first
    self.analysis_table_name = en_name.nil? ? nil : en_name.name.downcase.gsub(' ', '_').gsub('-', '').gsub('__', '_')
    return true
  end

  def delete_analysis_items
    delete_analysis_tables_and_views if self.analysis_table_name.present?
  end

  #######################################
  ## SCOPES
  scope :can_enter, where(can_enter_data: true)

  def self.by_election(election_id)
    where(election_id: election_id)
  end

  def self.by_election_district(election_id, district_id)
    by_election(election_id).where(district_id: district_id)
  end

  #######################################
  ## METHODS

  def election_year
    self.election_at.present? ? self.election_at.year : nil
  end

  # create the analysis tables and views for this election
  def create_analysis_items
    if self.analysis_table_name.empty?
      set_analysis_name
      self.save
    end

    if self.analysis_table_name.present?
      create_analysis_tables_and_views
    else
      puts "!!!!!!!!!!!!!!!!!!!!!!"
      puts "WARNING - ANALYSIS TABLES NAME DOES NOT EXIST"
      puts "!!!!!!!!!!!!!!!!!!!!!!"
    end
  end

  # create analysis precinct count for this election
  def create_analysis_precinct_counts
    if self.district_precincts.count > 0
      load_analysis_precinct_counts
    else
      puts "!!!!!!!!!!!!!!!!!!!!!!"
      puts "WARNING - DISTRICT/PRECINCTS MUST BE LOADED FOR THIS ELECTION IN ORDER TO CREATE PRECINCT COUNTS FOR ANALYSIS"
      puts "!!!!!!!!!!!!!!!!!!!!!!"
    end
  end

  # assign region names to district/precincts if this election needs it
  def assign_region_names
    if self.has_regions
      DistrictPrecinct.assign_region_name(self.id)
    end
  end

end
