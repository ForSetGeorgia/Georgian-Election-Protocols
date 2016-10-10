class Admin::ElectionDataController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:admin])
  end

  def index

    @current_election_migrations = ElectionDataMigration.sorted.by_election(@election_ids)


    gon.notification_url = admin_election_data_notification_url

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def reset_bad_protocol_data
    if @elections.nil?
      redirect_to admin_path, :notice => I18n.t('root.protocol.no_current_elections')
      return
    end

    if request.put?
      if params[:election_id].present? && params[:district_id].present? && params[:precinct_id].present?
        if DistrictPrecinct.reset_bad_data(params[:election_id], params[:district_id], params[:precinct_id])
          flash[:notice] = I18n.t('app.msgs.data_reset')
          params[:electon_id] = nil
          params[:district_id] = nil
          params[:precinct_id] = nil
        else
          flash[:alert] = I18n.t('app.msgs.could_not_rest')
        end
      else
        flash[:notice] = I18n.t('app.msgs.provide_all_params')
      end
    end

    respond_to do |format|
      format.html # index.html.erb
    end

  end

  def edit
    election = Election.find(params[:election_id])

    @record = election.get_analysis_record(:district_id => params[:district_id], :precinct_id => params[:precinct_id])

    if @record.present? && params[:president2013].present? && request.put?
logger.debug "******************************** form is put"
      if @record.update_attributes(params[:president2013])
        flash[:notice] = t('app.msgs.success_updated', :obj => t('activerecord.models.president2013'))
      else
        flash[:error] = t('app.msgs.no_success_updated', :obj => t('activerecord.models.president2013'))
      end

    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def create_migration
    Rails.logger.debug "$$$$$$$$$$$$$$$$ create_migration start for #{params[:id]}"
    msg = ''
    success = false
    data = {}

    election = Election.find(params[:id])
    migration = ElectionDataMigration.create_record(params[:id])

    if migration.present?
      success = true
      data['migration_url'] = site_url + ElectionDataMigration::PUSH_DATA_URL_PATH
      data['file_url'] = "#{request.protocol}#{request.host_with_port}#{migration.file_url_path}"
      data['precincts_completed'] = migration.num_precincts
      data['precincts_total'] = DistrictPrecinct.by_election(params[:id]).count
      data['event_id'] = election.election_app_event_id
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



  # recieve notification response from election data app
  # that indicates if the data migration push was successful
  def notification
Rails.logger.debug "+++++++++++++++++++++++++++++++++"
Rails.logger.debug "+++++++++++ notification_response start"
Rails.logger.debug "+++++++++++++++++++++++++++++++++"
Rails.logger.debug "+++++++++++ params = #{params}"

    if params[:success].present? && params[:file_url].present?
Rails.logger.debug "+++++++++++ params success and file_url present"

      file_name = params[:file_url].split('/').last
Rails.logger.debug "+++++++++++ file_name = #{file_name}"

      ElectionDataMigration.record_notification(file_name, params[:success], params[:msg])
    end

    render text: "OK"
  end



  protected

  def site_url
    url = 'http://localhost:3000/'

    if Rails.env.production?
      url = 'https://elections.jumpstart.ge/'
    elsif Rails.env.staging?
      url = 'http://dev-electiondata.jumpstart.ge/'
    end

    return url
  end


end
