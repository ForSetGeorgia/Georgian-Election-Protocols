require 'update_volunteers'

namespace :scrape do
  ##############################
  desc "register new protocol images"
  task :register_new_images => [:environment] do

    DistrictPrecinct.new_image_search
  end

  ##############################
  desc "add unpaid volunteers"
  task :register_volunteers => [:environment] do

    UpdateVolunteers.vol_update
  end

end
