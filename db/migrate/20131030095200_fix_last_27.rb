class FixLast27 < ActiveRecord::Migration
  def up
    DistrictPrecinct.transaction do
      dps = DistrictPrecinct.where(:is_validated => false)
      
      if dps.present?
        HasProtocol.delete_all

        # load all districts/precincts that exist
        sql = "insert into has_protocols (district_id, precinct_id) values "
        sql << dps.map{|x| "(#{x.district_id}, #{x.precinct_id})"}.uniq.join(", ")
        ActiveRecord::Base.connection.execute(sql)

        sql = "SELECT cd.* FROM crowd_data as cd inner join has_protocols as hp on cd.district_id = hp.district_id and cd.precinct_id = hp.precinct_id "
        sql << "where cd.is_valid = 1 order by cd.district_id, cd.precinct_id"
        crowd_data = CrowdDatum.find_by_sql(sql)
        
        puts "found #{crowd_data.present? ? crowd_data.length : 0} crowd records that are valid"
        completed = []
        not_completed = []
        if crowd_data.present?
          dps.each do |dp|
            matches = crowd_data.select{|x| x.district_id == dp.district_id && x.precinct_id == dp.precinct_id}
            if matches.present? && matches.length == 2
              completed << [dp.district_id, dp.precinct_id]
              if matches[0].attributes.except('id', 'created_at', 'updated_at', 'user_id', 'is_valid', 'is_extra') == matches[1].attributes.except('id', 'created_at', 'updated_at', 'user_id', 'is_valid', 'is_extra')

                # indicate that the precinct has been processed and validated
                DistrictPrecinct.where(["district_id = ? and precinct_id = ?", matches[0].district_id, matches[0].precinct_id]).update_all(:is_validated => true)

                # save pres record
                rd = RegionDistrictName.by_district(matches[0].district_id)
                pres = President2013.new
                pres.region = rd.present? ? rd.region : nil
                pres.district_id = matches[0].district_id
                pres.district_name = rd.present? ? rd.district_name : nil
                pres.precinct_id = matches[0].precinct_id
                pres.attached_precinct_id = nil
                pres.num_possible_voters = matches[0].possible_voters
                pres.num_special_voters = matches[0].special_voters
                pres.num_at_12 = matches[0].votes_by_1200
                pres.num_at_17 = matches[0].votes_by_1700
                pres.num_votes = matches[0].ballots_signed_for
                pres.num_ballots = matches[0].ballots_available
                pres.num_invalid_votes = matches[0].invalid_ballots_submitted
                pres['1 - Tamaz Bibiluri'] = matches[0].party_1
                pres['2 - Giorgi Liluashvili'] = matches[0].party_2
                pres['3 - Sergo Javakhidze'] = matches[0].party_3
                pres['4 - Koba Davitashvili'] = matches[0].party_4
                pres['5 - Davit Bakradze'] = matches[0].party_5
                pres['6 - Akaki Asatiani'] = matches[0].party_6
                pres['7 - Nino Chanishvili'] = matches[0].party_7
                pres['8 - Teimuraz Bobokhidze'] = matches[0].party_8
                pres['9 - Shalva Natelashvili'] = matches[0].party_9
                pres['10 - Giorgi Targamadze'] = matches[0].party_10
                pres['11 - Levan Chachua'] = matches[0].party_11
                pres['12 - Nestan Kirtadze'] = matches[0].party_12
                pres['13 - Giorgi Chikhladze'] = matches[0].party_13
                pres['14 - Nino Burjanadze'] = matches[0].party_14
                pres['15 - Zurab Kharatishvili'] = matches[0].party_15
                pres['16 - Mikheil Saluashvili'] = matches[0].party_16
                pres['17 - Kartlos Gharibashvili'] = matches[0].party_17
                pres['18 - Mamuka Chokhonelidze'] = matches[0].party_18
                pres['19 - Avtandil Margiani'] = matches[0].party_19
                pres['20 - Nugzar Avaliani'] = matches[0].party_20
                pres['21 - Mamuka Melikishvili'] = matches[0].party_21
                pres['22 - Teimuraz Mzhavia'] = matches[0].party_22
                pres['41 - Giorgi Margvelashvili'] = matches[0].party_41

                pres.save


              end

            else
              not_completed << [dp.district_id, dp.precinct_id]
            end
          end
        end
        puts "completed #{completed.length} records "
        puts "not completed #{not_completed.length} records: #{not_completed} "
        puts "# of districts/precincts not validated = #{DistrictPrecinct.where(:is_validated => false).count}"
      end
    end
  end

  def down
    # do nothing
  end
end
