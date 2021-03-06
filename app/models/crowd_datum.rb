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

  #######################################
  ## RELATIONSHIPS
  belongs_to :election

  #######################################
  ## ATTRIBUTES
  FOLDER_PATH = "/system/protocols"
  MAX_PARTIES = 60
  ANALYSIS_DB = 'protocol_analysis'

  attr_accessor :moderation_reason

  #######################################
  ## VALIDATIONS
  validates :election_id, :district_id, :precinct_id, :possible_voters, :ballots_signed_for, :presence => true

  validate :required_fields
  validate :party_votes_provided
 #validate :validate_numerical_values

  #######################################
  ## SCOPES

  # this will get existing records that have not been compared or have been marked as invalid
  # so even if record was invalid, it could still find match and become valid
  def self.existing_not_validated(election_id, district_id, major_district_id, precinct_id, user_id)
    if major_district_id.present?
      where(["election_id = ? and district_id = ? and major_district_id = ? and precinct_id = ? and user_id != ? and is_extra = 0 and (is_valid is null or is_valid = 0)",
        election_id, district_id, major_district_id, precinct_id, user_id])
    else
      where(["election_id = ? and district_id = ? and precinct_id = ? and user_id != ? and is_extra = 0 and (is_valid is null or is_valid = 0)",
        election_id, district_id, precinct_id, user_id])
    end
  end

  def self.by_ids(election_id, district_id, precinct_id)
    where(election_id: election_id, district_id: district_id, precinct_id: precinct_id)
  end

  def self.election_ids_with_valid_data
    where(is_valid: true).pluck(:election_id).uniq
  end

  def self.by_user(user_id)
    where(user_id: user_id)
  end

  #######################################
  ## CALLBACKS
  before_save :reset_majoritarian_id
  after_create :match_and_validate

  # if this record does not have a majoritarian id,
  # make sure the id is saved as nil and not ''
  def reset_majoritarian_id
    if self.major_district_id == '' || self.major_district_id == '0'
      self.major_district_id = nil
    end
  end

  # if another record exists for this district/precinct
  # and the district/precinct is not already approved
  # see if this record matches that already on file
  def match_and_validate
    puts "==> match_and_validate start"
    CrowdDatum.transaction do
      # finished queue item
      CrowdQueue.finished(self.election_id, self.district_id, self.major_district_id, self.precinct_id, self.user_id)

      # see if existing, not validated record exists
      existing = CrowdDatum.existing_not_validated(self.election_id, self.district_id, self.major_district_id, self.precinct_id, self.user_id)
      puts "==> existing count = #{existing.length}"

      if existing.present?
        puts "==> FOUND EXISTING!!"
        # see if same
        found_match = false
        existing.each do |exists|
          exists.is_valid = exists.attributes.except('id', 'created_at', 'updated_at', 'user_id', 'is_valid', 'is_extra') == self.attributes.except('id', 'created_at', 'updated_at', 'user_id', 'is_valid', 'is_extra')

          exists.save
          found_match = true if exists.is_valid
          puts "==> - exists = #{exists.id}; is valid = #{exists.is_valid}"

        end

        # update valid status
        self.is_valid = found_match
        self.save

        # if found match, copy data to analysis table
        # indicate that match found
        if found_match
          puts "==> match was found, saving to analysis table"

          # indicate that the precinct has been processed and validated
          dp = DistrictPrecinct.by_ids(self.election_id, self.district_id, self.precinct_id).first

          dp.is_validated = true
          dp.save

          # get election and parties
          election = self.election
          parties = election.parties
          rd = RegionDistrictName.by_district(self.district_id)

          # need to calcualte the following:
          # - valid votes (total - invalid)
          # - logic check fail (valid == sum parties)
          # - logic check difference (valid - sum parties)
          # - more ballots than votes (valid > sum parties)
          # - more ballots than votes amount (valid - sum parties if valid > sum, else 0)
          # - more votes than ballots (valid < sum parties)
          # - more votes than ballots amount (valid - sum parties if valid > sum, else 0)
          valid = self.ballots_signed_for - self.invalid_ballots_submitted
          sum_parties = 0
          parties.each do |p|
            sum_parties += self["party_#{p.number}"] if self["party_#{p.number}"].present?
          end
          logic_fail = valid != sum_parties ? 1 : 0
          logic_diff = valid -sum_parties
          ballots_votes = valid > sum_parties ? 1 : 0
          ballots_votes_amount = ballots_votes == true ? logic_diff : 0
          votes_ballots = valid < sum_parties ? 1 : 0
          votes_ballots_amount = votes_ballots == true ? logic_diff.abs : 0
          supplemental_documents_flag = dp.has_supplemental_documents? ? 1 : 0
          supplemental_document_count = dp.supplemental_document_count
          annulled = dp.is_annulled? ? 1 : 0
          amendment_flag = dp.has_amendment
          explanatory_note_flag = dp.has_explanatory_note

          # if the election has indeodent parties, add them all together
          # for election app can only show this as one result
          if election.has_indepenedent_parties?
            ind_parties = parties.select{|x| x.is_independent?}
            sum_ind_parties = 0
            ind_parties.each do |p|
              sum_ind_parties += self["party_#{p.number}"] if self["party_#{p.number}"].present?
            end
          end

          # insert the record
          client = ActiveRecord::Base.connection
          sql = "insert into `#{ANALYSIS_DB}`.`#{election.analysis_table_name} - raw` ("
          if election.has_regions?
            sql << "`region`, "
          end
          sql << "`district_id`, `district_name`, "
          if election.is_local_majoritarian?
            sql << "`major_district_id`, "
          end
          sql << "`precinct_id`,
                 `num_possible_voters`, `num_special_voters`, `num_at_12`, `num_at_17`, `num_votes`, `num_ballots`,
                 `num_invalid_votes`, `num_valid_votes`, `logic_check_fail`, `logic_check_difference`,
                 `more_ballots_than_votes_flag`, `more_ballots_than_votes`, `more_votes_than_ballots_flag`, `more_votes_than_ballots`,
                 `supplemental_documents_flag`, `supplemental_document_count`, `amendment_flag`, `explanatory_note_flag`, `is_annulled`, "
          sql << parties.map{|x| "`#{x.column_name}`"}.join(', ')
          if election.has_indepenedent_parties?
            sql << ", `#{Election::INDEPENDENT_MERGED_ANALYSIS_NAME}`"
          end
          sql << ") values ( "

          # create array of values
          sql_values = []
          if election.has_regions
            if rd.present?
              sql_values << rd.region
            else
              sql_values << nil
            end
          end
          sql_values << self.district_id
          if election.has_district_names && rd.present?
            sql_values << rd.district_name
          else
            sql_values << district_id
          end
          if election.is_local_majoritarian?
            sql_values << dp.major_district_id
          end
          sql_values << [
            self.precinct_id, self.possible_voters, self.special_voters,
            self.votes_by_1200, self.votes_by_1700, self.ballots_signed_for, self.ballots_available, self.invalid_ballots_submitted,
            valid, logic_fail, logic_diff, ballots_votes, ballots_votes_amount, votes_ballots, votes_ballots_amount,
            supplemental_documents_flag, supplemental_document_count, amendment_flag, explanatory_note_flag, annulled
          ]
          parties.each do |p|
            sql_values << self["party_#{p.number}"]
          end
          sql_values.flatten!
          if election.has_indepenedent_parties?
            sql_values << sum_ind_parties
          end

          sql << sql_values.map{|x| "'#{x}'"}.join(', ')
          sql << ")"


          client.execute(sql)

          # if there are enough new records, notify admins that migration can occur
          election.notify_if_can_migrate
        end
      else
        puts "==> no match, seeing if is extra"
        # check if this district/precinct has already been validated
        # if so, this is an extra
        dp = DistrictPrecinct.by_ids(self.election_id, self.district_id, self.precinct_id).first
        if dp.present?
          if dp.is_validated
            puts "====> is extra!"
            self.is_extra = true
            self.save
          end
        end
      end
    end
  end

  #######################
  #######################

  # get the path to the protocol image
  # if the file does not exist, return nil
  def image_path
    path = nil
    exist = false

    if self.election_id.present? && self.district_id.present? && self.precinct_id.present?
      sep = Election.by_election(election_id).pluck(:district_precinct_separator).first
      path = "#{FOLDER_PATH}/#{election_id}/#{district_id}/#{district_id}-#{precinct_id}.jpg"
      # puts "path = #{path}"
      # puts "exist = #{File.exist?("#{Rails.root}/public#{path}")}"
      exist = File.exist?("#{Rails.root}/public#{path}")
    end

    path = nil if !exist

    if path.present?
      # add random querystring to url so browsers see it as a new image
      path += "?#{SecureRandom.hex(8)}"
    end

    return path
  end

  # get the path to the protocol supplemental document image(s)
  # if the file does not exist, return nil
  def supplemental_document_image_paths
    path = nil

    if self.election_id.present? && self.district_id.present? && self.precinct_id.present?
      test_path = "#{FOLDER_PATH}/#{election_id}/#{district_id}/#{district_id}-#{precinct_id}_amendment_*.jpg"
      root = "#{Rails.root}/public"
      files = Dir.glob("#{root}#{test_path}")
      if files.present?
        path = []
        files.sort.each do |file|
          path << file.gsub(root, '')
        end
      end
    end

    return path
  end

  def required_fields
=begin # turning off since all values are default to 0
    [:possible_voters, :ballots_signed_for].each do |f|
      errors.add(f, I18n.t('errors.messages.blank')) if self[f.to_s].to_i == 0
    end
=end
  end

  # at least one party must have votes
  def party_votes_provided
    sum = 0
    (1..MAX_PARTIES).each do |party_id|
      sum += self["party_#{party_id}"] if !self["party_#{party_id}"].nil?
      break if sum > 0
    end

    if sum == 0
      errors.add(:base, I18n.t('activerecord.errors.messages.required_party_votes'))
    end
  end

  def self.extract_numbers(pairs)
    not_convert = ['district_id', 'district_name', 'precinct_id', 'major_district_id']

    pairs.each_pair do |key, val|
      if !not_convert.include?(key)
        val = val.to_s.downcase.strip
        if val.match(/[a-z]/)
          val = val.gsub(/^[a-z]+/, '').gsub(/[a-z]+$/, '')
        end
        if val == ''
          val = '0'
        # if the value starts with 0 but is in the not convert list, keep the 0
        elsif val.start_with?('0') && val.length > 1
          val = val.to_i.to_s
        end
        pairs[key] = val
      end
    end
    return pairs
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



  #######################
  #######################


  # use 3 queries to select from the next record
  # 1 - is there something needing a match
  # 2 - is there something that is invalid and needs a match
  # 3 - is there anything waiting for data entry
  # -> then the results from these 3 queries is chosen at random
  #    - this is so the users do not get stuck with re-entering protocols due to amendments
  #      - this gives them some variety
  def self.next_available_record(user_id)
    logger.info "=========== next available record"
    next_records = []
    next_record = nil
    weights = [0.9, 0.9, 0.1]
    next_record_weights = Hash.new

    # make sure the queue is clean
    CrowdQueue.clean_queue(user_id)

    # get active election ids
    e_ids = Election.can_enter.pluck(:id)

    user_records = by_user(user_id)

    logger.info "=========== query 1"
    # see if a record needs a match
    sql = "SELECT cd.id, cd.election_id, cd.district_id, cd.major_district_id, cd.precinct_id FROM `crowd_data` as cd left join ( "
    sql << "select cq.id, cq.election_id, cq.district_id, cq.major_district_id, cq.precinct_id from crowd_queues as cq where is_finished is null) "
    sql << "as y on cd.election_id = y.election_id and cd.district_id = y.district_id and cd.major_district_id = y.major_district_id and cd.precinct_id = y.precinct_id "
    sql << "WHERE cd.user_id != :user_id and cd.is_valid is null and cd.is_extra = 0 and y.id is null and cd.election_id in (:e_ids)"
    needs_match = CrowdDatum.find_by_sql([sql, :user_id => user_id, e_ids: e_ids])

    remove_user_records(user_records, needs_match)

    if needs_match.present?
      logger.info "=========== - found #{needs_match.length} records"
      # it is possible that next record may not have image, so check
      # if not have image after 5 attempts, stop
      (0..4).each do |try|
        # records exist that are waiting for a match
        rand = CrowdDatum.find_by_id(needs_match.map{|x| x.id}.sample)
        next_item = CrowdDatum.new(
          :election_id => rand.election_id,
          :district_id => rand.district_id,
          :major_district_id => rand.major_district_id,
          :precinct_id => rand.precinct_id,
          :user_id => user_id
        )
        if next_item.image_path.present?
          next_records << next_item
          next_record_weights[next_record_weights.keys.length] = weights[0]
          break
        end
      end
    end

    logger.info "=========== query 2"

    # see if a district/precinct has invalid records and is still not valid, show one
    sql = "SELECT dp.election_id, dp.district_id, dp.major_district_id, dp.precinct_id "
    sql << "FROM (select dp.election_id, dp.district_id, dp.major_district_id, dp.precinct_id, count(*) as c "
    sql << "from district_precincts as dp inner join crowd_data as cd on dp.election_id = cd.election_id and dp.district_id = cd.district_id and dp.major_district_id = cd.major_district_id and dp.precinct_id = cd.precinct_id "
    sql << "where dp.is_validated = 0 and dp.has_protocol = 1 and dp.is_annulled = 0 and (dp.being_moderated = 0 or dp.being_moderated is null) and cd.is_valid = 0 and cd.user_id != :user_id and cd.election_id in (:e_ids) "
    sql << "group by dp.election_id, dp.district_id, dp.major_district_id, dp.precinct_id having c > 1) as dp "
    sql << "left join ( select cq.id, cq.election_id, cq.district_id, cq.major_district_id, cq.precinct_id from crowd_queues as cq where cq.is_finished is null and cq.user_id != :user_id and cq.election_id in (:e_ids)) "
    sql << "as y on dp.election_id = y.election_id and dp.district_id = y.district_id and dp.major_district_id = y.major_district_id and dp.precinct_id = y.precinct_id WHERE y.id is null and dp.election_id in (:e_ids)"
    needs_match = DistrictPrecinct.find_by_sql([sql, :user_id => user_id, e_ids: e_ids])

    remove_user_records(user_records, needs_match)

    if needs_match.present?
      logger.info "=========== - found #{needs_match.length} records"

      # it is possible that next record may not have image, so check
      # if not have image after 5 attempts, stop
      (0..4).each do |try|
        # records exist that are waiting for a match
        rand = needs_match.sample
        next_item = CrowdDatum.new(
          :election_id => rand.election_id,
          :district_id => rand.district_id,
          :major_district_id => rand.major_district_id,
          :precinct_id => rand.precinct_id,
          :user_id => user_id
        )
        if next_item.image_path.present?
          next_records << next_item
          next_record_weights[next_record_weights.keys.length] = weights[1]
          break
        end
      end
    end

    # see if there are any precincts that are still waiting for processing that this user has not entered
    logger.info "=========== query 3"
=begin
  sql = "select district_id, precinct_id from district_precincts where has_protocol = 1 and is_validated = 0 "
  sql << "and id not in ( select dp.id from district_precincts as dp inner join crowd_data as cd "
  sql << "  on dp.district_id = cd.district_id and dp.precinct_id = cd.precinct_id "
  sql << "  where dp.has_protocol = 1 and dp.is_validated = 0 and cd.user_id = :user_id and (((cd.is_valid is null and cd.is_extra = 0) or cd.is_valid = 1)))"
=end
    sql = "select dp.election_id, dp.district_id, dp.major_district_id, dp.precinct_id from district_precincts as dp left join ( "
    sql << "select cd.id, cd.election_id, cd.district_id, cd.major_district_id, cd.precinct_id from crowd_data as cd where cd.is_valid is null and cd.election_id in (:e_ids) "
    sql << ") as x on dp.election_id = x.election_id and dp.district_id = x.district_id and dp.major_district_id = x.major_district_id and dp.precinct_id = x.precinct_id "
    sql << "left join (select cq.id, cq.election_id, cq.district_id, cq.major_district_id, cq.precinct_id from crowd_queues as cq "
    sql << "where is_finished is null and cq.election_id in (:e_ids)) as y on dp.election_id = y.election_id and dp.district_id = y.district_id and dp.major_district_id = y.major_district_id and dp.precinct_id = y.precinct_id "
    sql << "where dp.has_protocol = 1 and dp.is_validated = 0 and dp.is_annulled = 0 and (dp.being_moderated = 0 or dp.being_moderated is null) and x.id is null and y.id is null and dp.election_id in (:e_ids)"
    needs_processing = DistrictPrecinct.find_by_sql([sql, :user_id => user_id, e_ids: e_ids])

    remove_user_records(user_records, needs_processing)

    if needs_processing.present?
      logger.info "=========== - found #{needs_processing.length} records"
      # it is possible that next record may not have image, so check
      # if not have image after 5 attempts, stop
      (0..4).each do |try|
        # precincts are waiting for processing
        # create a new crowd data record so it can be processed
        rand = needs_processing.sample
        next_item = CrowdDatum.new(
          :election_id => rand.election_id,
          :district_id => rand.district_id,
          :major_district_id => rand.major_district_id,
          :precinct_id => rand.precinct_id,
          :user_id => user_id
        )
        if next_item.image_path.present?
          next_records << next_item
          next_record_weights[next_record_weights.keys.length] = weights[2]
          break
        end
      end
    end

    # now pick random next record
    if next_records.present?
      logger.info "=========== next_records count = #{next_records.length}"

      # use weights to get random item
      idx_next = weight_random_sample(next_record_weights)
      logger.info "=========== random index = #{idx_next}"
        # get the next item
      next_record = next_records[idx_next]
      CrowdQueue.create(
        :user_id => user_id,
        :election_id => next_record.election_id,
        :district_id => next_record.district_id,
        :major_district_id => next_record.major_district_id,
        :precinct_id => next_record.precinct_id
      )
    end

    return next_record
  end


  #######################
  #######################
  # get the following:
  # total users (#), total submitted (#), pending (#/%), valid (#/%), invalid (#/%)
  def self.overall_user_stats(election_ids)
    stats = nil

    if election_ids.present?
      election_ids = [election_ids] if election_ids.class.name == 'Fixnum'

      # get the count of users assigned to the elections
      user_count = User.in_election(election_ids).uniq.count

  #    sql = "select sum(if(is_extra = 0, 1, 0)) as num_submitted, sum(if(is_valid is null and is_extra = 0, 1, 0)) as num_pending, "
  #    sql << "sum(if(is_valid = 1, 1, 0)) as num_valid, sum(if(is_valid = 0, 1, 0)) as num_invalid "
  #    sql << "from crowd_data"

      sql = "select count(*) as num_submitted, sum(if(is_valid is null and is_extra = 0, 1, 0)) as num_pending, "
      sql << "sum(if(is_valid = 1, 1, 0)) as num_valid, sum(if(is_valid = 0, 1, 0)) as num_invalid, sum(if(is_extra = 1, 1, 0)) as num_extra "
      sql << "from crowd_data where election_id in (?)"

      data = find_by_sql([sql, election_ids])

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
    end
    return stats

  end

  #######################
  #######################
  # get the following for a user:
  # user id, total submitted (#), pending (#/%), valid (#/%), invalid (#/%)
  def self.overall_stats_for_user(user_id, election_ids)
    stats = nil

    if user_id.present? && election_ids.present?
      election_ids = [election_ids] if election_ids.class.name == 'Fixnum'

      sql = "select count(*) as num_submitted, sum(if(is_valid is null and is_extra = 0, 1, 0)) as num_pending, "
      sql << "sum(if(is_valid = 1, 1, 0)) as num_valid, sum(if(is_valid = 0, 1, 0)) as num_invalid, sum(if(is_extra = 1, 1, 0)) as num_extra "
      sql << "from crowd_data where user_id = :user_id and election_id in (:election_ids)"

      data = find_by_sql([sql, :user_id => user_id, election_ids: election_ids])

      if data.present?
        total_remaining = DistrictPrecinct.where(election_id: election_ids).to_validate.count
        total_precincts = DistrictPrecinct.where(election_id: election_ids).count

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
        stats[:remaining] = format_number(total_remaining)
        stats[:total_precincts] = format_number(total_precincts)
      end
    end
    return stats
  end

  #######################
  #######################
  # get the following for a user:
  # user id, total submitted (#), pending (#/%), valid (#/%), invalid (#/%)
  # if election_ids provided then only get stats for the provided elections, else do it for all elections
  def self.overall_stats_by_user(election_ids=nil)
    users = []

    sql = "select user_id, count(*) as num_submitted, sum(if(is_valid is null and is_extra = 0, 1, 0)) as num_pending, "
    sql << "sum(if(is_valid = 1, 1, 0)) as num_valid, sum(if(is_valid = 0, 1, 0)) as num_invalid, sum(if(is_extra = 1, 1, 0)) as num_extra "
    sql << "from crowd_data "

    if election_ids.present?
      election_ids = [election_ids] if election_ids.class.name == 'Fixnum'
      sql << "where election_id in (?) "
    end

    sql << "group by user_id"

    data = find_by_sql([sql, election_ids])

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

  # use weights to pick a random item in a hash
  # format of hash should be: item to return (key), weight (value)
  # taken from: https://gist.github.com/O-I/3e0654509dd8057b539a
  def self.weight_random_sample(hash)
    hash.max_by { |_, weight| rand ** (1.0 / weight) }.first
  end



  def self.format_number(number)
    ActionController::Base.helpers.number_with_delimiter(ActionController::Base.helpers.number_with_precision(number))
  end

  def self.format_percent(number)
    ActionController::Base.helpers.number_to_percentage(ActionController::Base.helpers.number_with_precision(number))
  end


  # the querries are supposed to remove the user records
  # but they still get the same record, so this is a back up
  # to make sure there are none being returned
  # - look for matches with same election, district and precinct
  def self.remove_user_records(user_records, needs_matches)
    logger.info ")))))))))))))))))))))))"
    logger.info "remove_user_records start"
    logger.info ")))))))))))))))))))))))"
    if user_records.present? && needs_matches.present?
      found_matches = []
      user_records.each do |user_record|
        found_matches << needs_matches.select{|x| x.election_id == user_record.election_id &&
                          x.district_id == user_record.district_id &&
                          x.major_district_id == user_record.major_district_id &&
                          x.precinct_id == user_record.precinct_id}
      end

      found_matches.flatten!

      if found_matches.present?

        logger.info "!!!!!! found #{found_matches.length} matches out of #{needs_matches.length} records"

        found_matches.each do |found_match|
          needs_matches.delete(found_match)
        end
        logger.info "!!!!!! > needs_matches now has #{needs_matches.length} records"
      end
    end
    logger.info ")))))))))))))))))))))))"
    logger.info "remove_user_records end"
    logger.info ")))))))))))))))))))))))"
  end

end
