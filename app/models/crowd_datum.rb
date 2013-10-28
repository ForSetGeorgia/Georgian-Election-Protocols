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

  validates :district_id, :precinct_id, :possible_voters, :ballots_signed_for, :presence => true

  validate :party_votes_provided
 #validate :validate_numerical_values

  after_create :match_and_validate

  FOLDER_PATH = "/system/protocols"

  #######################
  #######################

  # get the path to the protocol image
  # if the file does not exist, return nil
  def image_path
    path = nil
    exist = false
    
    if self.district_id.present? && self.precinct_id.present?
      path = "#{FOLDER_PATH}/#{district_id}/#{district_id}-#{precinct_id}.jpg"
      exist = File.exist?("#{Rails.root}/public#{path}")
    end
    
    path = nil if !exist

    return path
  end

  # get the path to the protocol amendment image
  # if the file does not exist, return nil
  def amendment_image_path
    path = nil
    exist = false
    
    if self.district_id.present? && self.precinct_id.present?
      path = "#{FOLDER_PATH}/#{district_id}/#{district_id}-#{precinct_id}-amended.jpg"
      exist = File.exist?("#{Rails.root}/public#{path}")
    end
    
    path = nil if !exist

    return path
  end

  # at least one party must have votes
  def party_votes_provided
    parties = [self.party_1, self.party_2, self.party_3, self.party_4, self.party_5, self.party_6, self.party_7, self.party_8, self.party_9, self.party_10, self.party_11, self.party_12, self.party_13, self.party_14, self.party_15, self.party_16, self.party_17, self.party_18, self.party_19, self.party_20, self.party_21, self.party_22, self.party_41]    

    sum = 0
    parties.each do |party|
      sum += party
    end

    if sum == 0
      errors.add(:base, I18n.t('activerecord.errors.messages.required_party_votes'))
    end
  end

=begin
  def self.numerical_values_provided(fields)
    needed = [:possible_voters, :special_voters, :votes_by_1200, :votes_by_1700, :ballots_signed_for, :ballots_available, :invalid_ballots_submitted,
              :party_1, :party_2, :party_3, :party_4, :party_5, :party_6, :party_7, :party_8, :party_9, :party_10, :party_11, :party_12,
              :party_13, :party_14, :party_15, :party_16, :party_17, :party_18, :party_19, :party_20, :party_21, :party_22, :party_41]

    errors = []
    needed.each do |key|
      val = fields[key]
      if !val.nil? && val.length > 0 && !!val.to_s.match(/[a-zA-Z]/)
        errors.push([key, I18n.t('errors.messages.not_a_number')])
      end
    end
    @@numerical_errors = errors
  end

  def validate_numerical_values
    if @@numerical_errors.present?
      @@numerical_errors.each do |nm|
        errors.add(nm[0], nm[1]);
      end
    end
  end
=end

  def self.extract_numbers (pairs)
    pairs.each_pair do |key, val|
      val = val.to_s.downcase
      if val.include? 'x'
        val = val.gsub(/^x+/, '').gsub(/x+$/, '')
      end
      if val == ''
        val = '0'
      elsif val.start_with?('0') && val.length > 1
        val = val.to_i.to_s
      end
      pairs[key] = val
    end
    return pairs
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
      # it is possible that next record may not have image, so check
      # if not have image after 5 attempts, stop
      (0..4).each do |try|
        # records exist that are waiting for a match
        rand = CrowdDatum.find_by_id(needs_match.map{|x| x.id}.sample)
        next_record = CrowdDatum.new(:district_id => rand.district_id, :precinct_id => rand.precinct_id, :user_id => user_id)
        break if next_record.image_path.present?
      end
    else
      # see if there are any precincts that are still waiting for processing that this user has not entered
      sql = "select district_id, precinct_id from district_precincts where has_protocol = 1 and is_validated = 0 "
      sql << "and id not in ( select dp.id from district_precincts as dp inner join crowd_data as cd "
      sql << "  on dp.district_id = cd.district_id and dp.precinct_id = cd.precinct_id "
      sql << "  where dp.has_protocol = 1 and dp.is_validated = 0 and cd.user_id = :user_id and (((cd.is_valid is null and cd.is_extra = 0) or cd.is_valid = 1)))"
      needs_processing = DistrictPrecinct.find_by_sql([sql, :user_id => user_id])

      if needs_processing.present?
        # it is possible that next record may not have image, so check
        # if not have image after 5 attempts, stop
        (0..4).each do |try|
          # precincts are waiting for processing
          # create a new crowd data record so it can be processed
          rand = needs_processing.sample
          next_record = CrowdDatum.new(:district_id => rand.district_id, :precinct_id => rand.precinct_id, :user_id => user_id)
          break if next_record.image_path.present?
        end
      end
    end

    return next_record
  end


  #######################
  #######################
  # get the following:
  # total users (#), total submitted (#), pending (#/%), valid (#/%), invalid (#/%)
  def self.overall_user_stats
    stats = nil

    user_count = User.count

#    sql = "select sum(if(is_extra = 0, 1, 0)) as num_submitted, sum(if(is_valid is null and is_extra = 0, 1, 0)) as num_pending, "
#    sql << "sum(if(is_valid = 1, 1, 0)) as num_valid, sum(if(is_valid = 0, 1, 0)) as num_invalid "
#    sql << "from crowd_data"

    sql = "select count(*) as num_submitted, sum(if(is_valid is null and is_extra = 0, 1, 0)) as num_pending, "
    sql << "sum(if(is_valid = 1, 1, 0)) as num_valid, sum(if(is_valid = 0, 1, 0)) as num_invalid, sum(if(is_extra = 1, 1, 0)) as num_extra "
    sql << "from crowd_data"

    data = find_by_sql(sql)

    if data.present?
      data = data.first
      stats = Hash.new
      stats[:users] = format_number(user_count)
      stats[:submitted] = data[:num_submitted].present? ? format_number(data[:num_submitted]) : 0
      stats[:pending] = Hash.new
      stats[:pending][:number] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_number(data[:num_pending]) : I18n.t('app.common.na')
      stats[:pending][:percent] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_percent(100*data[:num_pending]/data[:num_submitted].to_f) : I18n.t('app.common.na')
      stats[:valid] = Hash.new
      stats[:valid][:number] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_number(data[:num_valid]) : I18n.t('app.common.na')
      stats[:valid][:percent] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_percent(100*data[:num_valid]/data[:num_submitted].to_f) : I18n.t('app.common.na')
      stats[:invalid] = Hash.new
      stats[:invalid][:number] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_number(data[:num_invalid]) : I18n.t('app.common.na')
      stats[:invalid][:percent] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_percent(100*data[:num_invalid]/data[:num_submitted].to_f) : I18n.t('app.common.na')
      stats[:extra] = Hash.new
      stats[:extra][:number] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_number(data[:num_extra]) : I18n.t('app.common.na')
      stats[:extra][:percent] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_percent(100*data[:num_extra]/data[:num_submitted].to_f) : I18n.t('app.common.na')
    end
    return stats

  end

  #######################
  #######################
  # get the following for a user:
  # user id, total submitted (#), pending (#/%), valid (#/%), invalid (#/%)
  def self.overall_stats_for_user(user_id)
    stats = nil

    if user_id.present?

#      sql = "select sum(if(is_extra = 0, 1, 0)) as num_submitted, sum(if(is_valid is null and is_extra = 0, 1, 0)) as num_pending, "
#      sql << "sum(if(is_valid = 1, 1, 0)) as num_valid, sum(if(is_valid = 0, 1, 0)) as num_invalid "
#      sql << "from crowd_data where user_id = :user_id"

      sql = "select count(*) as num_submitted, sum(if(is_valid is null and is_extra = 0, 1, 0)) as num_pending, "
      sql << "sum(if(is_valid = 1, 1, 0)) as num_valid, sum(if(is_valid = 0, 1, 0)) as num_invalid, sum(if(is_extra = 1, 1, 0)) as num_extra "
      sql << "from crowd_data where user_id = :user_id"


      data = find_by_sql([sql, :user_id => user_id])

      if data.present?
        data = data.first
        stats = Hash.new
        stats[:user_id] = user_id
        stats[:submitted] = data[:num_submitted].present? ? format_number(data[:num_submitted]) : 0
        stats[:pending] = Hash.new
        stats[:pending][:number] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_number(data[:num_pending]) : I18n.t('app.common.na')
        stats[:pending][:percent] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_percent(100*data[:num_pending]/data[:num_submitted].to_f) : I18n.t('app.common.na')
        stats[:valid] = Hash.new
        stats[:valid][:number] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_number(data[:num_valid]) : I18n.t('app.common.na')
        stats[:valid][:percent] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_percent(100*data[:num_valid]/data[:num_submitted].to_f) : I18n.t('app.common.na')
        stats[:invalid] = Hash.new
        stats[:invalid][:number] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_number(data[:num_invalid]) : I18n.t('app.common.na')
        stats[:invalid][:percent] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_percent(100*data[:num_invalid]/data[:num_submitted].to_f) : I18n.t('app.common.na')
        stats[:extra] = Hash.new
        stats[:extra][:number] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_number(data[:num_extra]) : I18n.t('app.common.na')
        stats[:extra][:percent] = data[:num_submitted].present? && data[:num_submitted] > 0 ? format_percent(100*data[:num_extra]/data[:num_submitted].to_f) : I18n.t('app.common.na')
      end
    end
    return stats
  end

  #######################
  #######################
  # get the following for a user:
  # user id, total submitted (#), pending (#/%), valid (#/%), invalid (#/%)
  def self.overall_stats_by_user
    users = []

#    sql = "select user_id, sum(if(is_extra = 0, 1, 0)) as num_submitted, sum(if(is_valid is null and is_extra = 0, 1, 0)) as num_pending, "
#    sql << "sum(if(is_valid = 1, 1, 0)) as num_valid, sum(if(is_valid = 0, 1, 0)) as num_invalid "
#    sql << "from crowd_data group by user_id"

    sql = "select count(*) as num_submitted, sum(if(is_valid is null and is_extra = 0, 1, 0)) as num_pending, "
    sql << "sum(if(is_valid = 1, 1, 0)) as num_valid, sum(if(is_valid = 0, 1, 0)) as num_invalid, sum(if(is_extra = 1, 1, 0)) as num_extra "
    sql << "from crowd_data group by user_id"

    data = find_by_sql(sql)

    if data.present?
      data.each do |user|
        stats = Hash.new
        users << stats
        stats[:user_id] = user[:user_id]
        stats[:submitted] = user[:num_submitted].present? ? format_number(user[:num_submitted]) : 0
        stats[:pending] = Hash.new
        stats[:pending][:number] = user[:num_submitted].present? && user[:num_submitted] > 0 ? format_number(user[:num_pending]) : I18n.t('app.common.na')
        stats[:pending][:percent] = user[:num_submitted].present? && user[:num_submitted] > 0 ? format_percent(100*user[:num_pending]/user[:num_submitted].to_f) : I18n.t('app.common.na')
        stats[:valid] = Hash.new
        stats[:valid][:number] = user[:num_submitted].present? && user[:num_submitted] > 0 ? format_number(user[:num_valid]) : I18n.t('app.common.na')
        stats[:valid][:percent] = user[:num_submitted].present? && user[:num_submitted] > 0 ? format_percent(100*user[:num_valid]/user[:num_submitted].to_f) : I18n.t('app.common.na')
        stats[:invalid] = Hash.new
        stats[:invalid][:number] = user[:num_submitted].present? && user[:num_submitted] > 0 ? format_number(user[:num_invalid]) : I18n.t('app.common.na')
        stats[:invalid][:percent] = user[:num_submitted].present? && user[:num_submitted] > 0 ? format_percent(100*user[:num_invalid]/user[:num_submitted].to_f) : I18n.t('app.common.na')
        stats[:extra] = Hash.new
        stats[:extra][:number] = user[:num_submitted].present? && user[:num_submitted] > 0 ? format_number(user[:num_extra]) : I18n.t('app.common.na')
        stats[:extra][:percent] = user[:num_submitted].present? && user[:num_submitted] > 0 ? format_percent(100*user[:num_extra]/user[:num_submitted].to_f) : I18n.t('app.common.na')
      end
    end
    return users
  end



  protected 


  def self.format_number(number)
    ActionController::Base.helpers.number_with_delimiter(ActionController::Base.helpers.number_with_precision(number))
  end

  def self.format_percent(number)
    ActionController::Base.helpers.number_to_percentage(ActionController::Base.helpers.number_with_precision(number))
  end


end
