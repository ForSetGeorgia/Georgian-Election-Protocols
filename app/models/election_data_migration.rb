class ElectionDataMigration < ActiveRecord::Base
	require 'fileutils'
  require 'utf8_converter'

  MIN_PRECINCTS_CHANGE = 50
  FILE_PATH = "#{Rails.root}/public/system/election_data_migrations/"
  URL_PATH = "/system/election_data_migrations/"
  
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
  
  
  def self.push_data
    pushed = false
    
    precinct_count = President2013.count
    
    if (precinct_count - last_precinct_count) >= MIN_PRECINCTS_CHANGE
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
      
      # push the data to the election site
            
            
      pushed = true
    end
    
    return pushed
  
  end

  def self.record_notification(file_name)
    ElectionDataMigration.where(:file_name => file_name).update_all(:recieved_success_notification_at => Time.now)
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
end
