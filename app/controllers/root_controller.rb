class RootController < ApplicationController

  def index
    @overall_stats = DistrictPrecinct.overall_stats
    @overall_user_stats = CrowdDatum.overall_user_stats
  end


end
