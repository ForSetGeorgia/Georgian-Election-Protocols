class ElectionDataMigration < ActiveRecord::Base
	require 'fileutils'
  require 'utf8_converter'
  require 'net/http'

  MIN_PRECINCTS_CHANGE = 2
  FILE_PATH = "#{Rails.root}/public/system/election_data_migrations/"
  URL_PATH = "/system/election_data_migrations/"
  
  PUSH_DATA_URL_PATH = "en/migration/load_data/from_protocols_app"
   
  scope :sorted, order("created_at desc")

  def file_url_path
    URL_PATH + self.file_name if self.file_name.present?    
  end
  
  def self.last_precinct_count
    count = 0
    x = select('num_precincts').order('created_at desc').limit(1)
    count = x.first.num_precincts if x.present?
    
    return count
  end
  
  
  def self.create_record
Rails.logger.debug "################## create migration record"
    migration = nil
    
    precinct_count = President2013.count
    
    if (precinct_count - last_precinct_count) >= MIN_PRECINCTS_CHANGE
Rails.logger.debug "################## need to send data!"
      # create record
      migration = ElectionDataMigration.new(:num_precincts => precinct_count)

      # get the csv data
      csv = President2013.download_election_map_data    
      # create directory if not exist
      FileUtils.mkpath(FILE_PATH)
      # save file
  	  filename = clean_filename("#{I18n.t('app.common.file_name')}-#{I18n.l Time.now, :format => :file}") + ".csv"
      File.open(FILE_PATH + filename, 'w') {|f| f.write(csv) }

      migration.file_name = filename
      
      migration.save
Rails.logger.debug "################## created migration record: #{migration.inspect}"
      
    end
    
Rails.logger.debug "################## create migration end"
    return migration
  end


  def self.push_data_old(current_domain, respond_to_url)
Rails.logger.debug "################## push data start"
    pushed = false
    
    precinct_count = President2013.count
    
    if (precinct_count - last_precinct_count) >= MIN_PRECINCTS_CHANGE
Rails.logger.debug "################## need to send data!"
      # create record
      migration = ElectionDataMigration.new(:num_precincts => precinct_count)

      # get the csv data
      csv = President2013.download_election_map_data    
      # create directory if not exist
      FileUtils.mkpath(FILE_PATH)
      # save file
  	  filename = clean_filename("#{I18n.t('app.common.file_name')}-#{I18n.l Time.now, :format => :file}") + ".csv"
      File.open(FILE_PATH + filename, 'w') {|f| f.write(csv) }

      migration.file_name = filename
      
      migration.save
Rails.logger.debug "################## created migration record: #{migration.inspect}"
      
Rails.logger.debug "################## sending data"
      # push the data to the election site
      uri = URI(site_url + PUSH_DATA_URL_PATH)
Rails.logger.debug "################## uri = #{uri.inspect}"
      res = Net::HTTP.post_form(uri, {'event_id' => event_id, 'file_url' => current_domain + migration.file_url_path,
        'precincts_completed' => migration.num_precincts, 'precincts_total' => DistrictPrecinct.count,
        'respond_to_url' => respond_to_url})

      pushed = true
    end
    
Rails.logger.debug "################## push data end"
    return pushed
  end

  def self.record_notification(file_name, success, message)
    ElectionDataMigration.where(:file_name => file_name)
      .update_all(:recieved_success_notification_at => Time.now, :success => success, :notification_msg => message)
  end


  protected
  
	# remove bad characters from file name
	def self.clean_filename(filename)
		Utf8Converter.convert_ka_to_en(filename.gsub(' ', '_').gsub(/[\\ \/ \: \* \? \" \< \> \| \, \. ]/,''))
	end
  
  def self.site_url
    url = 'http://localhost:3000/'
    
    if Rails.env.production?
      url = 'http://data.electionportal.ge/'
    elsif Rails.env.staging?
      url = 'http://dev-electiondata.jumpstart.ge/'
    end
    
    return url
  end


  def self.event_id
    event_id = 42
    
    if Rails.env.production?
      event_id = 38
    elsif Rails.env.staging?
      event_id = 38
    end
    
    return event_id
  end
end
