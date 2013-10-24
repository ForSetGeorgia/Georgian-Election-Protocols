class JsonController < ApplicationController

  def missing_protocols
    respond_to do |format|
      format.json { render json: DistrictPrecinct.missing_protocols}
    end
  end
  
  def mark_found_protocols
    success = false
    if params[:data].present?    
      success = DistrictPrecinct.mark_found_protocols(JSON.parse(params[:data]))
    end
      
    respond_to do |format|
      format.json { render json: success}
    end
  end


  # recieve notification response from election data app
  # that indicates if the data migration push was successful
  def election_data_notification
Rails.logger.debug "+++++++++++++++++++++++++++++++++"
Rails.logger.debug "+++++++++++ notification_response start"
Rails.logger.debug "+++++++++++++++++++++++++++++++++"
Rails.logger.debug "+++++++++++ params = #{params}"

    if params[:success].present? && params[:file_url].present?
Rails.logger.debug "+++++++++++ params success and file_url present"

      file_name = params[:file_url].split('/').last
Rails.logger.debug "+++++++++++ file_name = #{file_name}"
  
      ElectionDataMigration.record_notification(params[:success], params[:msg], file_name)
    end

    render text: "OK"
  end


end
