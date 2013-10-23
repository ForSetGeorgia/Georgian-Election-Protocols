class CrowdDatum < ActiveRecord::Base

  #######################
  # flag descriptions
  #######################
  # is_valid
  # - by default is null which means that it has not been matched and validated against a matching district/precinct
  # - 0 = it was matched and validation failed
  # - 1 = it was matched and validated
  
  # is_extra
  # - 0 = default value
  # - 1 = when matched and validated, the district/precinct was already validated so this record is extra
  #######################


  #######################
  #######################

  validates :district_id, :precinct_id, :possible_voters, :special_voters, 
    :votes_by_1200, :votes_by_1700, :ballots_signed_for, :ballots_available, 
    :invalid_ballots_submitted, :presence => true
    
  validate :party_votes_provided  

  after_create :match_and_validate  

  #######################
  #######################
  
  # at least one party must have votes
  def party_votes_provided
    has_value = false
    parties = [self.party_1, self.party_2, self.party_3, self.party_4, self.party_5, self.party_6, self.party_7, self.party_8, self.party_9, self.party_10, self.party_11, self.party_12, self.party_13, self.party_14, self.party_15, self.party_16, self.party_17, self.party_18, self.party_19, self.party_20, self.party_21, self.party_22, self.party_41]    
    
    parties.each do |party|
      if party.present?
        has_value = true
        break
      end
    end
    
    if !has_value
      errors.add(:base, I18n.t('activerecord.errors.messages.required_party_votes'))
    end
  end



  # if another record exists for this district/precinct 
  # and the district/precinct is not already approved
  # see if this record matches that already on file
  def match_and_validate
    CrowdDatum.transaction do
      existing = CrowdDatum.where(["district_id = ? and precinct_id = ? and user_id != ? and is_valid is null and is_extra = 0", self.district_id, self.precinct_id, self.user_id])
      
      if existing.present?
        # see if same
        matches = true
        existing.each do |exists|
          matches = false if exists.attributes.except('id', 'created_at', 'updated_at', 'user_id', 'is_valid', 'is_extra') != self.attributes.except('id', 'created_at', 'updated_at', 'user_id', 'is_valid', 'is_extra')
        end

        # update valid status
        self.is_valid = matches
        self.save
        existing.each do |exists|
          exists.is_valid = matches
          exists.save
        end

        # if found match, copy data to pres table
        # indicate that match found
        if matches
          # indicate that the precinct has been processed and validated
          DistrictPrecinct.where(["district_id = ? and precinct_id = ?", self.district_id, self.precinct_id]).update_all(:is_validated => true)

          # save pres record
          rd = RegionDistrictName.by_district(self.district_id)
          pres = President2013.new  
          pres.region = rd.present? ? rd.region : nil
          pres.district_id = self.district_id
          pres.district_name = rd.present? ? rd.district_name : nil
          pres.precinct_id = self.precinct_id
          pres.attached_precinct_id = nil
          pres.num_possible_voters = self.possible_voters
          pres.num_special_voters = self.special_voters
          pres.num_at_12 = self.votes_by_1200
          pres.num_at_17 = self.votes_by_1700
          pres.num_votes = self.ballots_signed_for
          pres.num_ballots = self.ballots_available
          pres.num_invalid_votes = self.invalid_ballots_submitted
          pres['1 - Tamaz Bibiluri'] = self.party_1
          pres['2 - Giorgi Liluashvili'] = self.party_2
          pres['3 - Sergo Javakhidze'] = self.party_3
          pres['4 - Koba Davitashvili'] = self.party_4
          pres['5 - Davit Bakradze'] = self.party_5
          pres['6 - Akaki Asatiani'] = self.party_6
          pres['7 - Nino Chanishvili'] = self.party_7
          pres['8 - Teimuraz Bobokhidze'] = self.party_8
          pres['9 - Shalva Natelashvili'] = self.party_9
          pres['10 - Giorgi Targamadze'] = self.party_10
          pres['11 - Levan Chachua'] = self.party_11
          pres['12 - Nestan Kirtadze'] = self.party_12
          pres['13 - Giorgi Chikhladze'] = self.party_13
          pres['14 - Nino Burjanadze'] = self.party_14
          pres['15 - Zurab Kharatishvili'] = self.party_15
          pres['16 - Mikheil Saluashvili'] = self.party_16
          pres['17 - Kartlos Gharibashvili'] = self.party_17
          pres['18 - Mamuka Chokhonelidze'] = self.party_18
          pres['19 - Avtandil Margiani'] = self.party_19
          pres['20 - Nugzar Avaliani'] = self.party_20
          pres['21 - Mamuka Melikishvili'] = self.party_21
          pres['22 - Teimuraz Mzhavia'] = self.party_22
          pres['41 - Giorgi Margvelashvili'] = self.party_41
          pres.num_valid_votes = pres.calculate_valid_votes
          pres.logic_check_fail = pres.calculate_logic_check_fail
          pres.logic_check_difference = pres.calculate_logic_check_difference 
          pres.more_ballots_than_votes_flag = pres.calculate_more_ballots_than_votes_flag
          pres.more_ballots_than_votes = pres.calculate_more_ballots_than_votes
          pres.more_votes_than_ballots_flag = pres.calculate_more_votes_than_ballots_flag
          pres.more_votes_than_ballots = pres.calculate_more_votes_than_ballots
          
          pres.save
          
        
        end
      else
        # check if this district/precinct has already been validated
        # if so, this is an extra
        dp = DistrictPrecinct.where(["district_id = ? and precinct_id = ?", self.district_id, self.precinct_id])
        if dp.present?
          if dp.first.is_validated
            self.is_extra = true
            self.save
          end
        end
      end
    end
  end


  #######################
  #######################


  # get the next record to be processed
  def self.next_available_record(user_id)
    next_record = nil
    needs_match = CrowdDatum.select('id').where("user_id != ? and is_valid is null and is_extra = 0", user_id)
    if needs_match.present?
      # records exist that are waiting for a match
      rand = CrowdDatum.find_by_id(needs_match.map{|x| x.id}.sample)
      next_record = CrowdDatum.new(:district_id => rand.district_id, :precinct_id => rand.precinct_id, :user_id => user_id)
       
    else
      # see if there are any precincts that are still waiting for processing
      needs_processing = DistrictPrecinct.select('district_id, precinct_id').where(:is_validated => false)
      
      if needs_processing.present?
        # precincts are waiting for processing
        # create a new crowd data record so it can be processed
        rand = needs_processing.sample
        next_record = CrowdDatum.new(:district_id => rand.district_id, :precinct_id => rand.precinct_id, :user_id => user_id) 
      end
    end
    
    return next_record
  end




end
