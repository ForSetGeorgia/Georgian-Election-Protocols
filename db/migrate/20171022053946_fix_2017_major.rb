class Fix2017Major < ActiveRecord::Migration
  def up
    # for some reason some of the precincts did not get the major district id loaded
    # so have to update district/precinct, crowd data and crowd queue
    DistrictPrecinct.transaction do

      election = Election.includes(:election_translations).where(election_translations: {name: '2017 Local Election - Majoritarian'}).first

      csv_path = "#{Rails.root}/db/data/2017/2017_major_districts_precincts.csv"
      idx_district = 0
      idx_major = 1
      idx_precinct = 2
      data = CSV.read(csv_path)

      # get all the records that need to be updated
      items = [
        DistrictPrecinct.where(election_id: election.id).where('major_district_id is null'),
        CrowdDatum.where(election_id: election.id).where('major_district_id is null'),
        CrowdQueue.where(election_id: election.id).where('major_district_id is null')
      ].flatten
      if items.present?
        items.each do |item|
          row = data.select{|x| x[idx_district] == item.district_id && x[idx_precinct] == item.precinct_id}.first
          if row.present?
            item.major_district_id = row[idx_major]
            item.save
          end
        end
      end


      puts "district precincts that are still bad - #{DistrictPrecinct.where(election_id: election.id).where('major_district_id is null').count}"
      puts "crowd data that are still bad - #{CrowdDatum.where(election_id: election.id).where('major_district_id is null').count}"
      puts "crowd queue that are still bad - #{CrowdQueue.where(election_id: election.id).where('major_district_id is null').count}"

    end

  end

  def down
    puts "do nothing"
  end
end
