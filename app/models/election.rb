class Election < ActiveRecord::Base
  require 'data_analysis' # script in lib folder that has methods to create analysis tables, run them, and delete them
  include DataAnalysis

  INDEPENDENT_MERGED_ANALYSIS_NAME = 'Independent Merged'
  INDEPENDENT_MERGED_CSV_NAME = 'Initiative Group'


  #######################################
  ## TRANSLATIONS
  translates :name

  #######################################
  ## RELATIONSHIPS
  has_many :parties, :dependent => :destroy
  has_many :district_parties, :dependent => :destroy
  has_many :district_precincts, :dependent => :destroy
  has_many :election_translations, :dependent => :destroy
  has_many :election_users, :dependent => :destroy
  has_many :users, :through => :election_users
  has_many :crowd_data, :dependent => :destroy
  has_many :crowd_queues, :dependent => :destroy
  has_many :has_protocols, :dependent => :destroy
  accepts_nested_attributes_for :election_translations

  #######################################
  ## ATTRIBUTES
  attr_accessible :parties_same_for_all_districts, :can_enter_data, :is_local_majoritarian, :has_indepenedent_parties,
                  :has_regions, :has_district_names, :election_app_event_id, :election_at, :election_translations_attributes,
                  :max_party_in_district, :protocol_top_box_margin, :protocol_party_top_margin, :district_precinct_separator,
                  :scraper_url_base, :scraper_url_folder_to_images, :scraper_page_pattern, :has_custom_shape_levels

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
    where(id: election_id)
  end

  def self.by_election_district(election_id, district_id)
    by_election(election_id).where(district_id: district_id)
  end

  def self.sorted
    with_translations(I18n.locale).order('elections.election_at desc, election_translations.name asc')
  end

  def self.with_data
    where(id: CrowdDatum.election_ids_with_valid_data)
  end

  def self.by_analysis_table_name(analysis_table_name)
    where(analysis_table_name: analysis_table_name).first
  end

  # election_at is >= today-1
  # - -1 is because the election data is usually not available until the day after
  def self.coming_up
    where('can_enter_data = 0 and election_at >= ?', (Time.now-1.day).to_date)
  end

  # determine if this election has same parties for all districts
  def self.are_parties_same_for_all_districts?(election_id)
    by_election(election_id).pluck(:parties_same_for_all_districts).first
  end

  #######################################
  ## METHODS

  def election_year
    self.election_at.present? ? self.election_at.year : nil
  end

  def is_coming_up?
    self.election_at >= (Time.now-1.day).to_date
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
