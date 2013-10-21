class JsonController < ApplicationController

  def missing_protocols
    respond_to do |format|
      format.json { render json: DistrictPrecinct.missing_protocols}
    end
  end


end
