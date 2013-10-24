class Admin::ElectionDataController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:admin])
  end

  def index
  
    if params[:push] == "data"
      @push_created = ElectionDataMigration.push_data
    end
  
    @current_precinct_count = President2013.count
    @migrations = ElectionDataMigration.sorted

    respond_to do |format|
      format.html # index.html.erb
    end
  end


end
