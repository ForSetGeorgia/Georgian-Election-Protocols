class Admin::ElectionDataController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:admin])
  end

  def index
    
    if params[:push] == "data"
      if ElectionDataMigration.push_data("#{request.protocol}#{request.host_with_port}", json_election_data_notification_url)
        flash[:success] = I18n.t('admin.election_data.index.push_success')
      else
        flash[:notice] = I18n.t('admin.election_data.index.push_fail')
      end
    end
  
    @current_precinct_count = President2013.count
    @migrations = ElectionDataMigration.sorted

    respond_to do |format|
      format.html # index.html.erb
    end
  end



end
