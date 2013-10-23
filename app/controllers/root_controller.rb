class RootController < ApplicationController

  def index
    @overall_stats = DistrictPrecinct.overall_stats
  end


end
