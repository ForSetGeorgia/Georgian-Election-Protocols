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

  has_attached_file :party_file,
                    :url => "/system/elections/:id/:analysis_table_name__parties.:extension",
                    :use_timestamp => false

  has_attached_file :district_precinct_file,
                    :url => "/system/elections/:id/:analysis_table_name__districts_precincts.:extension",
                    :use_timestamp => false

  has_attached_file :party_district_file,
                    :url => "/system/elections/:id/:analysis_table_name__party_districts.:extension",
                    :use_timestamp => false

  attr_accessible :parties_same_for_all_districts, :can_enter_data, :is_local_majoritarian, :has_indepenedent_parties,
                  :has_regions, :has_district_names, :election_app_event_id, :election_at, :election_translations_attributes,
                  :max_party_in_district, :protocol_top_box_margin, :protocol_party_top_margin, :district_precinct_separator,
                  :scraper_url_base, :scraper_url_folder_to_images, :scraper_page_pattern, :has_custom_shape_levels,
                  :party_file, :district_precinct_file, :party_district_file, :tmp_analysis_table_name
  attr_accessor :reset_max_party_num, :tmp_analysis_table_name

  #######################################
  ## VALIDATIONS
  validates :election_at, :presence => true
  validates :election_app_event_id, :presence => true, if: 'can_enter_data == true'
  validates :tmp_analysis_table_name, length: { maximum: 32 }
  validates_attachment_content_type :party_file, :content_type => 'text/csv'
  validates_attachment_content_type :district_precinct_file, :content_type => 'text/csv'
  validates_attachment_content_type :party_district_file, :content_type => 'text/csv'

  #######################################
  ## CALLBACKS
  before_save :set_analysis_name
  after_save :load_parties
  after_save :load_district_precincts
  after_save :load_party_districts
  after_destroy :delete_analysis_items
  after_commit :reset_max_party_in_district
  before_save :check_if_can_enter_data
  after_create :add_moderators

  # when an election is created, automatically add moderators/admins
  def add_moderators
    self.users << User.with_role(User::ROLES[:moderator])
  end

  # check if the election is setup properly so can enter data
  # the following must exist to enter data
  # - party_file
  # - district_precinct_file
  # - party_district_file if !parties_same_for_all_districts
  # - scraper_url_base
  # - scraper_url_folder_to_images
  # - scraper_page_pattern
  def check_if_can_enter_data
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts "check_if_can_enter_data"
    puts "- change = #{self.can_enter_data_changed?}, can enter = #{self.can_enter_data?}"
    is_valid = true
    if self.can_enter_data_changed? && self.can_enter_data?
      puts "- changed!"
      if !self.has_parties?
        puts '- party file does not exist!'
        is_valid = false
        errors.add(:party_file, I18n.t('app.msgs.required_for_can_enter_data'))
      end
      if !self.has_district_precincts?
        puts '- district precinct file does not exist!'
        is_valid = false
        errors.add(:district_precinct_file, I18n.t('app.msgs.required_for_can_enter_data'))
      end
      if !self.parties_same_for_all_districts? && !self.has_party_districts?
        puts '- party district file does not exist!'
        is_valid = false
        errors.add(:party_district_file, I18n.t('app.msgs.required_for_can_enter_data'))
      end
      if self.scraper_url_base.empty?
        puts '- scraper url base does not exist!'
        is_valid = false
        errors.add(:scraper_url_base, I18n.t('app.msgs.required_for_can_enter_data'))
      end
      if self.scraper_url_folder_to_images.empty?
        puts '- scraper url folder to images does not exist!'
        is_valid = false
        errors.add(:scraper_url_folder_to_images, I18n.t('app.msgs.required_for_can_enter_data'))
      end
      if self.scraper_page_pattern.empty?
        puts '- scraper page pattern does not exist!'
        is_valid = false
        errors.add(:scraper_page_pattern, I18n.t('app.msgs.required_for_can_enter_data'))
      end
    end

    return is_valid
  end

  # if the list of district parties changed, update the max party in district value
  def reset_max_party_in_district
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts "reset_max_party_in_district"
    puts "- #{self.reset_max_party_num == true}"
    if self.reset_max_party_num == true
      # reset the flag so this is not called anymore
      self.reset_max_party_num = false

      self.max_party_in_district = DistrictParty.where(election_id: self.id).group(:district_id).count.values.max
      self.save
    end

    return true
  end

  # there is a limit on table name characters
  # - have to limit the total length to 32 characters in order for the analysis view to be generated properly
  def set_analysis_name
    if self.tmp_analysis_table_name.present? && self.analysis_table_name.nil?
      self.analysis_table_name = self.tmp_analysis_table_name.downcase.gsub(' ', '_').gsub('-', '').gsub('__', '_')
    end
    return true
  end

  def delete_analysis_items
    delete_analysis_tables_and_views if self.analysis_table_name.present?

    return true
  end


  # load the parties if a new file was loaded
  # - have to recreate the analysis views if parties change
  def load_parties
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts "load_parties"
    puts "- change = #{self.party_file_updated_at_changed?}, exists = #{self.party_file.exists?}"
    if self.party_file_updated_at_changed? && self.party_file.exists?
      puts "- changed!"

      parties = self.parties.with_translations(I18n.locale)
      puts "- there were #{parties.length} parties in db"

      puts '- only add new parties'
      csv_data = CSV.read(self.party_file.path)
      csv_data.each_with_index do |row, i|
        if i > 0
          # only add if this party is not in the system
          if parties.select{|x| x.number.to_s == row[0].to_s && x.name == row[1]}.empty?
            # puts "-- adding party #{row[0]} - #{row[1]}"
            is_independent = row[2].present? && row[2].to_s.downcase == 'true'
            p = self.parties.create(number: row[0], is_independent: is_independent)
            p.party_translations.create(locale: 'en', name: row[1])
            p.party_translations.create(locale: 'ka', name: row[1])
          end
        end
      end
      puts "  - added #{self.parties.length} parties"

      puts "- now see if we have parties that are no longer needed"
      ids_to_delete = []
      parties.each do |party|
        if csv_data.select{|row| row[0].to_s == party.number.to_s && row[1] == party.name}.empty?
          ids_to_delete << party.id
        end
      end
      puts "  - deleting #{ids_to_delete.length} parties that are not used anymore"
      Party.where(id: ids_to_delete).delete_all if ids_to_delete.present?

      puts "- recreating all analysis items"
      self.create_analysis_items
    end

    return true
  end


  # load the district precincts if a new file was loaded
  # - if there are new precincts, the precinct count table must be reloaded
  def load_district_precincts
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts "load_district_precincts"
    puts "- change = #{self.district_precinct_file_updated_at_changed?}, exists = #{self.district_precinct_file.exists?}"
    if self.district_precinct_file_updated_at_changed? && self.district_precinct_file.exists?
      puts "- changed!"
      client = ActiveRecord::Base.connection
      now = Time.now

      puts '- getting existing districts/precincts'
      dps = self.district_precincts
      puts "- there were #{dps.length} district precincts in db"

      puts '- load precincts/districts'
      csv_data = CSV.read(self.district_precinct_file.path)
      sql_values = []
      csv_data.each_with_index do |row, i|
        if i > 0
          # if the district/precint does not exist, add it
          if dps.select{|x| x.district_id == row[0] && x.precinct_id == row[1]}.empty?
            sql_values << "(#{self.id}, '#{row[0]}', '#{row[1]}', '#{now}')"
          end
        end
      end
      puts "  - adding #{sql_values.length} precincts"
      if sql_values.present?
        client.execute("insert into district_precincts
          (`election_id`, `district_id`, `precinct_id`, `created_at`)
          values #{sql_values.join(', ')}"
        )
      end

      puts "- now see if we have precincts that are no longer needed"
      ids_to_delete = []
      dist_prec_to_delete = []
      dps.each do |dp|
        if csv_data.select{|row| row[0] == dp.district_id && row[1] == dp.precinct_id}.empty?
          ids_to_delete << dp.id
          dist_prec_to_delete << [dp.district_id, dp.precinct_id]
        end
      end
      puts "  - deleting #{ids_to_delete.length} precincts that are not real"
      DistrictPrecinct.where(id: ids_to_delete).delete_all if ids_to_delete.present?

      puts '  - delete records from analysis table that are no longer needed'
      self.delete_raw_data(dist_prec_to_delete)

      # load the precinct count
      self.create_analysis_precinct_counts

      # load the region names
      self.assign_region_names
    end

    return true
  end

  # load the party district if a new file was loaded
  # - if there are a change in parties in a district, reload the max party in district
  def load_party_districts
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts "load_party_districts"
    puts "- parties same = #{self.parties_same_for_all_districts?}; change = #{self.party_district_file_updated_at_changed?}, exists = #{self.party_district_file.exists?}"
    if !self.parties_same_for_all_districts? && self.party_district_file_updated_at_changed? && self.party_district_file.exists?
      client = ActiveRecord::Base.connection
      now = Time.now

      dps = self.district_parties
      puts "- there were #{dps.length} district parties in db"

      puts '- only add new parties'
      csv_data = CSV.read(self.party_district_file.path)
      sql_values = []
      csv_data.each_with_index do |row, i|
        if i > 0
          # only add if this party is not in the system
          if dps.select{|x| x.party_number.to_s == row[1].to_s && x.district_id == row[0]}.empty?
            # puts "-- adding district party #{row[0]} / #{row[1]}"
            sql_values << "(#{self.id}, '#{row[0]}', '#{row[1]}', '#{now}')"
          end
        end
      end
      puts "  - adding #{sql_values.length} district parties"
      if sql_values.present?
        client.execute("insert into district_parties
          (`election_id`, `district_id`, `party_number`, `created_at`)
          values #{sql_values.join(', ')}"
        )
      end

      puts "- now see if we have parties that are no longer needed"
      ids_to_delete = []
      dps.each do |dp|
        if csv_data.select{|row| row[1].to_s == dp.party_number.to_s && row[0] == dp.district_id}.empty?
          ids_to_delete << dp.id
        end
      end
      puts "  - deleting #{ids_to_delete.length} district parties that are not used anymore"
      DistrictParty.where(id: ids_to_delete).delete_all if ids_to_delete.present?


      # load the max party value
      self.reset_max_party_num = true

    end

    return true
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

  def has_parties?
    self.parties.count > 0
  end

  def has_district_precincts?
    self.district_precincts.count > 0
  end

  def has_party_districts?
    if !self.parties_same_for_all_districts?
      return self.district_parties.count > 0
    end
    return nil
  end

  # determine if closed, on going or coming up
  def status
    if self.is_coming_up? && !self.can_enter_data?
      I18n.t('activerecord.attributes.election.status_types.coming_up')
    elsif self.can_enter_data?
      I18n.t('activerecord.attributes.election.status_types.ongoing')
    else
      I18n.t('activerecord.attributes.election.status_types.completed')
    end
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
