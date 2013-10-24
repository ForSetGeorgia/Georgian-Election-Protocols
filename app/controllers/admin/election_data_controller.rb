class Admin::ElectionDataController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:admin])
  end

  def index
    
    @current_precinct_count = President2013.count
    @migrations = ElectionDataMigration.sorted
    @min_precinct_change = ElectionDataMigration::MIN_PRECINCTS_CHANGE
    @last_precinct_count = ElectionDataMigration.last_precinct_count

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def create_migration
    Rails.logger.debug "$$$$$$$$$$$$$$$$ create_migration start"
    msg = ''
    success = false
    data = {}

    migration = ElectionDataMigration.create_record
    
    if migration.present?
      success = true
      data['migration_url'] = site_url + ElectionDataMigration::PUSH_DATA_URL_PATH
      data['file_url'] = "#{request.protocol}#{request.host_with_port}#{migration.file_url_path}"
      data['precincts_completed'] = migration.num_precincts
      data['precincts_total'] = DistrictPrecinct.count
      data['event_id'] = event_id
      data['respond_to_url'] = json_election_data_notification_url
    end
    
    if success
    Rails.logger.debug "$$$$$$$$$$$$$$$$ success!"
      msg = I18n.t('admin.election_data.index.push_success')
    else
    Rails.logger.debug "$$$$$$$$$$$$$$$$ fail!"
      msg = I18n.t('admin.election_data.index.push_fail')
    end

    respond_to do |format|
      format.json { render json: {'success' => success, 'msg' => msg, 'data' => data}.to_json}
    end
  end


  protected
  
  def site_url
    url = 'http://localhost:3000/'
    
    if Rails.env.production?
      url = 'http://data.electionportal.ge/'
    elsif Rails.env.staging?
      url = 'http://dev-electiondata.jumpstart.ge/'
    end
    
    return url
  end


  def event_id
    event_id = 42
    
    if Rails.env.production?
      event_id = 38
    elsif Rails.env.staging?
      event_id = 38
    end
    
    return event_id
  end

end
