class JsonController < ApplicationController

  def found_protocols
    respond_to do |format|
      format.json { render json: DistrictPrecinct.found_protocols}
    end
  end

  def missing_protocols
    respond_to do |format|
      format.json { render json: DistrictPrecinct.missing_protocols}
    end
  end

  def all_protocols
    respond_to do |format|
      format.json { render json: DistrictPrecinct.all_protocols}
    end
  end

  # def mark_found_protocols
  #   success = false
  #   if params[:data].present?
  #     success = DistrictPrecinct.mark_found_protocols(JSON.parse(params[:data]))
  #   end

  #   respond_to do |format|
  #     format.json { render json: success}
  #   end
  # end

end
