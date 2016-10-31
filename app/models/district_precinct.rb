class DistrictPrecinct < ActiveRecord::Base
  @@analysis_db = 'protocol_analysis'

  #######################################
  ## RELATIONSHIPS
  has_many :supplemental_documents
  belongs_to :election

  #######################################
  ## ATTRIBUTES
  MODERATION_REASONS = {bad_image: 1, missing_info: 2, cant_read: 3, docs_not_clear: 4, annulled: 5}
  MODERATION_STATUS = {waiting: 0, request_image: 1, annulled: 2, contact_cec: 3, supplementary_document_added: 4, no_problem: 5}

  attr_accessible :election_id, :district_id, :precinct_id,
                  :has_protocol, :is_validated, :is_annulled,
                  :has_supplemental_documents, :supplemental_document_count,
                  :has_amendment, :has_explanatory_note, :supplemental_documents_attributes,
                  :being_moderated, :moderation_reason, :issue_reported_by_user_id, :issue_reported_at,
                  :last_moderation_update_by_user_id, :last_moderation_updated_at,
                  :moderation_status, :moderation_notes

  attr_accessor :num_precincts, :num_protocols_found, :num_protocols_missing, :num_protocols_not_entered, :num_protocols_validated

  #######################################
  ## VALIDATIONS
  validates :election_id, :district_id, :precinct_id, :presence => true

  #######################################
  ## SCOPES
  def self.by_election(election_id)
    where(election_id: election_id)
  end

  def self.by_ids(election_id, district_id, precinct_id)
    where(election_id: election_id, district_id: district_id, precinct_id: precinct_id)
  end

  def self.with_protocols
    where(:has_protocol => true).order("election_id, district_id, precinct_id")
  end

  def self.awaiting_protocols
    where(:has_protocol => false).order("election_id, district_id, precinct_id")
  end

  def self.district_count_by_election(election_id)
    select('distinct district_id').by_election(election_id).count
  end

  def self.has_been_annulled
    where(is_annulled: true)
  end

  def self.with_supplemental_documents
    where(has_supplemental_documents: true)
  end

  def self.needs_moderation
    where(being_moderated: true)
  end

  def self.was_moderated
    where(being_moderated: false)
  end

  def self.with_elections
    includes(:election)
  end

  def self.sort_issue_reported_at
    order('issue_reported_at desc')
  end

  #######################
  # flag descriptions
  #######################
  # has_protocol
  # - 0 = default value
  # - 1 = set to true when scrapper indicates that it found the protocol

  # is_validated
  # - 0 = default value
  # - 1 = set to true two crowd datum records have matched and the data has been moved to raw table

  # is_annulled (protocol no longer valid)
  # - 0 = default value
  # - 1 = set to true when find amemendment that indicates the protocol is annulled

  # being_moderated
  # - by default is null which means that it has never been moderated
  # - 0 = it was moderated and is finished
  # - 1 = it is currently being moderated

  #######################


  #######################
  #######################

  # assign region name to records for election
  def self.assign_region_name(election_id)
    region_districts = RegionDistrictName.sorted
    if region_districts.present?
      regions = region_districts.map{|x| x.region}.uniq

      regions.each do |region|
        district_ids = region_districts.select{|x| x.region == region}.map{|x| x.district_id}.uniq
        DistrictPrecinct.where(election_id: election_id, district_id: district_ids).update_all(region: region)
      end
    end
  end

  # creates array of districts/precincts that have protocols
  #format: [ {election_id => a, districts => [ { district_id => [ precinct_id, precinct_id,   ] } ] } ]
  def self.found_protocols
    # records = []
    elections = Election.can_enter
    records = with_protocols.by_election(elections.map{|x| x.id})
    all_districts = by_election(elections.map{|x| x.id})

    return build_api_request(elections, records, all_districts)
  end


  # creates array of districts/precincts that are missing protocols
  #format: [ {election_id => a, districts => [ { district_id => [ precinct_id, precinct_id,   ] } ] } ]
  def self.missing_protocols
    # records = []
    elections = Election.can_enter
    records = awaiting_protocols.by_election(elections.map{|x| x.id})
    all_districts = by_election(elections.map{|x| x.id})

    return build_api_request(elections, records, all_districts)
  end

  # creates array of all districts/precincts (for searching for supplemental docs)
  #format: [ {election_id => a, districts => [ { district_id => [ precinct_id, precinct_id,   ] } ] } ]
  def self.all_protocols
    # records = []
    elections = Election.can_enter
    records = by_election(elections.map{|x| x.id})
    all_districts = by_election(elections.map{|x| x.id})

    return build_api_request(elections, records, all_districts)
  end


  # for each precinct in a district, if it is marked as found, update the table record
  def self.mark_found_protocols(json)
    success = true

    if json.present?
      DistrictPrecinct.transaction do
        json.each do |district|
          if district.has_key?('district_id') && district['district_id'].present? &&
              district.has_key?('precincts') && district['precincts'].present?

            district['precincts'].each do |precinct|
              if precinct.has_key?('id') && precinct['id'].present? &&
                  precinct.has_key?('found') && precinct['found'].present? &&
                  (precinct['found'] == true || precinct['found'] == 'true')

                # found district/precinct that has a protocol
                # - update the record
                u = DistrictPrecinct.where(:district_id => district['district_id'], :precinct_id => precinct['id'])
                  .update_all(:has_protocol => true)

                if u == 0
                  success = false
	                raise ActiveRecord::Rollback
                  return success
                end

              end
            end
          end
        end
      end
    end

    return success
  end


  #######################
  ## stats
  #######################

  # get the following:
  # total districts (#), total precincts (#), protocols found (#/%), protocols missing (#/%), protocols not entered (#/%), protocols validated (#/%)
  def self.overall_stats(election_ids)
    election_stats = []

    election_ids = [election_ids] if election_ids.class.name != 'Array'

    # only continue if there are elections running
    if election_ids.present?
      election_ids.each do |election_id|
        dist_count = self.district_count_by_election(election_id)

        sql = "select count(*) as num_precincts, sum(has_protocol) as num_protocols_found, (count(*) - sum(has_protocol)) as num_protocols_missing, "
        sql << "sum(if(has_protocol = 1 and is_validated = 0, 1, 0)) as num_protocols_not_entered, sum(if(has_protocol = 1 and is_validated = 1, 1, 0)) as num_protocols_validated "
        sql << "from district_precincts where election_id = ?"

        data = find_by_sql([sql, election_id])

        if data.present?
          data = data.first
          stats = Hash.new
          stats[:election_id] = election_id
          stats[:districts] = format_number(dist_count)
          stats[:precincts] = format_number(data[:num_precincts])
          stats[:protocols_missing] = Hash.new
          stats[:protocols_missing][:number] = format_number(data[:num_protocols_missing])
          stats[:protocols_missing][:percent] = format_percent(100*data[:num_protocols_missing]/data[:num_precincts].to_f)
          stats[:protocols_found] = Hash.new
          stats[:protocols_found][:number] = format_number(data[:num_protocols_found])
          stats[:protocols_found][:percent] = format_percent(100*data[:num_protocols_found]/data[:num_precincts].to_f)
          stats[:protocols_not_entered] = Hash.new
          stats[:protocols_not_entered][:number] = data[:num_protocols_found] > 0 ? format_number(data[:num_protocols_not_entered]) : I18n.t('app.common.na')
          stats[:protocols_not_entered][:percent] = data[:num_protocols_found] > 0 ? format_percent(100*data[:num_protocols_not_entered]/data[:num_protocols_found].to_f) : I18n.t('app.common.na')
          stats[:protocols_validated] = Hash.new
          stats[:protocols_validated][:number] = data[:num_protocols_found] > 0 ? format_number(data[:num_protocols_validated]) : I18n.t('app.common.na')
          stats[:protocols_validated][:percent] = data[:num_protocols_found] > 0 ? format_percent(100*data[:num_protocols_validated]/data[:num_protocols_found].to_f) : I18n.t('app.common.na')

          election_stats << stats
        end
      end
    end

    return election_stats
  end


  # get the following:
  # district id/name, total precincts (#), protocols found (#/%), protocols missing (#/%), protocols not entered (#/%), protocols validated (#/%)
  def self.overall_stats_by_district(election_ids)
    election_stats = []

    election_ids = [election_ids] if election_ids.class.name != 'Array'

    # only continue if there are elections running
    if election_ids.present?
      election_ids.each do |election_id|

        election = Election.where(id: election_id).first

        if election.has_regions || election.has_district_names
          regions = RegionDistrictName.sorted
        end

        sql = "select district_id, count(*) as num_precincts, sum(has_protocol) as num_protocols_found, (count(*) - sum(has_protocol)) as num_protocols_missing, "
        sql << "sum(if(has_protocol = 1 and is_validated = 0, 1, 0)) as num_protocols_not_entered, sum(if(has_protocol = 1 and is_validated = 1, 1, 0)) as num_protocols_validated "
        sql << "from district_precincts where election_id = ? group by district_id order by district_id"

        data = find_by_sql([sql, election_id])

        if data.present?
          stats = Hash.new
          stats[:election_id] = election_id
          stats[:districts] = []
          data.each do |district|
            district_stats = Hash.new
            stats[:districts] << district_stats

            if regions.present?
              region = regions.select{|x| x.district_id.to_s == district[:district_id]}.first
              if region.present?
                district_stats[:region] = region.region
                district_stats[:district] = region.district_name
              end
            end
            district_stats[:district_id] = district[:district_id]
            district_stats[:precincts] = format_number(district[:num_precincts])
            district_stats[:protocols_missing] = Hash.new
            district_stats[:protocols_missing][:number] = format_number(district[:num_protocols_missing])
            district_stats[:protocols_missing][:percent] = format_percent(100*district[:num_protocols_missing]/district[:num_precincts].to_f)
            district_stats[:protocols_found] = Hash.new
            district_stats[:protocols_found][:number] = format_number(district[:num_protocols_found])
            district_stats[:protocols_found][:percent] = format_percent(100*district[:num_protocols_found]/district[:num_precincts].to_f)
            district_stats[:protocols_not_entered] = Hash.new
            district_stats[:protocols_not_entered][:number] = district[:num_protocols_found] > 0 ? format_number(district[:num_protocols_not_entered]) : I18n.t('app.common.na')
            district_stats[:protocols_not_entered][:percent] = district[:num_protocols_found] > 0 ? format_percent(100*district[:num_protocols_not_entered]/district[:num_protocols_found].to_f) : I18n.t('app.common.na')
            district_stats[:protocols_validated] = Hash.new
            district_stats[:protocols_validated][:number] = district[:num_protocols_found] > 0 ? format_number(district[:num_protocols_validated]) : I18n.t('app.common.na')
            district_stats[:protocols_validated][:percent] = district[:num_protocols_found] > 0 ? format_percent(100*district[:num_protocols_validated]/district[:num_protocols_found].to_f) : I18n.t('app.common.na')
          end

          election_stats << stats
        end
      end
    end
    return election_stats
  end

  ############################################
  ############################################
  def self.reset_bad_data(election_id, district_id, precinct_id)
    record_count = 0
    DistrictPrecinct.transaction do
      client = ActiveRecord::Base.connection
      election = Election.find(election_id)

      if election.present?
        record_count += DistrictPrecinct.by_ids(election_id, district_id, precinct_id)
                        .update_all(is_validated: false, has_supplemental_documents: false, supplemental_document_count: 0,
                                    has_amendment: false, has_explanatory_note: false)
        record_count += CrowdDatum.by_ids(election_id, district_id, precinct_id)
                        .update_all(is_valid: false)

        # delete analysis record
        sql = "delete from `#{@@analysis_db}`.`#{election.analysis_table_name} - raw`
                where district_id = '#{district_id}'
                and precinct_id = '#{precinct_id}'"
        client.execute(sql)
      end
    end

    return record_count > 0
  end

  ############################################
  ############################################
  def self.add_moderation(election_id, district_id, precinct_id, user_id, moderation_reason)
    record_count = 0
    DistrictPrecinct.transaction do
      client = ActiveRecord::Base.connection
      election = Election.find(election_id)

      if election.present?
        moderation_reason.delete('')
        record_count += DistrictPrecinct.by_ids(election_id, district_id, precinct_id)
                        .update_all(is_validated: false, being_moderated: true,
                          issue_reported_by_user_id: user_id, issue_reported_at: Time.now,
                          moderation_reason: moderation_reason.join(','))
        record_count += CrowdDatum.by_ids(election_id, district_id, precinct_id)
                        .update_all(is_valid: false)

        # delete analysis record
        sql = "delete from `#{@@analysis_db}`.`#{election.analysis_table_name} - raw`
                where district_id = '#{district_id}'
                and precinct_id = '#{precinct_id}'"
        client.execute(sql)
      end
    end

    return record_count > 0
  end


  ############################################
  ############################################
  def self.cancel_moderation(id, moderator_user_id)
    DistrictPrecinct.transaction do
      dp = find(id)
      if dp.present?
        dp.moderation_status = MODERATION_STATUS[:no_problem]
        dp.being_moderated = false
        dp.last_moderation_update_by_user_id = moderator_user_id
        dp.last_moderation_updated_at = Time.now
        dp.save
      end
    end

    return true
  end

  ############################################
  ############################################
  def self.add_moderation_notes(id, notes, moderator_user_id)
    DistrictPrecinct.transaction do
      dp = find(id)
      if dp.present?
        dp.moderation_notes = notes.strip
        dp.last_moderation_update_by_user_id = moderator_user_id
        dp.last_moderation_updated_at = Time.now
        dp.save
      end
    end

    return true
  end

  ############################################
  ############################################
  def self.mark_as_annulled(id, moderator_user_id)
    dp = find(id)
    if dp.present?
      DistrictPrecinct.transaction do
        # update the dp record
        dp.is_annulled = true
        dp.moderation_status = MODERATION_STATUS[:annulled]
        dp.being_moderated = false
        dp.last_moderation_update_by_user_id = moderator_user_id
        dp.last_moderation_updated_at = Time.now
        dp.save

        # update the analysis raw table
        client = ActiveRecord::Base.connection
        sql = "update `#{@@analysis_db}`.`#{dp.election.analysis_table_name} - raw`
              set is_annulled = 1 where district_id = '#{dp.district_id}' and precinct_id = '#{dp.precinct_id}'"
        client.execute(sql)

      end
    end

    return true
  end

  ############################################
  ############################################
  def self.mark_as_contact_cec(id, moderator_user_id)
    dp = find(id)
    if dp.present?
      DistrictPrecinct.transaction do
        # update the dp record
        dp.moderation_status = MODERATION_STATUS[:contact_cec]
        dp.being_moderated = true
        dp.last_moderation_update_by_user_id = moderator_user_id
        dp.last_moderation_updated_at = Time.now
        dp.save
      end
    end

    return true
  end

  ############################################
  ############################################
  def self.mark_as_supplementary_document_added(id, moderator_user_id)
    dp = find(id)
    if dp.present?
      DistrictPrecinct.transaction do
        # update the dp record
        dp.moderation_status = MODERATION_STATUS[:supplementary_document_added]
        dp.being_moderated = false
        dp.last_moderation_update_by_user_id = moderator_user_id
        dp.last_moderation_updated_at = Time.now
        dp.save
      end
    end

    return true
  end


  ############################################
  ############################################
  def self.request_new_image(id, moderator_user_id)
    record_count = 0
    DistrictPrecinct.transaction do
      dp = find(id)
      if dp.present?

        client = ActiveRecord::Base.connection
        election = dp.election

        if election.present?
          success = dp.update_attributes(has_protocol: false, is_validated: false, has_supplemental_documents: false,
                                      supplemental_document_count: 0,
                                      has_amendment: false, has_explanatory_note: false,
                                      moderation_status: MODERATION_STATUS[:request_image],
                                      last_moderation_update_by_user_id: moderator_user_id,
                                      being_moderated: false, last_moderation_updated_at: Time.now)
          record_count += 1 if success == true
          record_count += CrowdDatum.by_ids(dp.election_id, dp.district_id, dp.precinct_id)
                          .update_all(is_valid: false)

          # delete analysis record
          sql = "delete from `#{@@analysis_db}`.`#{election.analysis_table_name} - raw`
                  where district_id = '#{dp.district_id}'
                  and precinct_id = '#{dp.precinct_id}'"
          client.execute(sql)

          # now delete the existing protocol images
          files = Dir.glob("#{Rails.root}/public/system/protocols/#{dp.election_id}/#{dp.district_id}/#{dp.district_id}-#{dp.precinct_id}*.jpg")
          if files.present?
            files.each do |f|
              begin
                logger_info.info("Deleting: #{f}")
                FileUtils.rm(f)
              rescue => e
                logger_error.error("Failed to delete: #{f}")
              end
            end
          end
        end
      end
    end

    return record_count > 0
  end


  ############################################
  ############################################
  # folder format: /election_id/district_id/majorid-precinct_id[_amendment_*].jpg
  def self.new_image_search
    root = "#{Rails.root}/public"
    files = Dir.glob("#{root}/system/protocols/**/*.jpg")
    puts "==> there are #{files.length} protocol images"
    if files.present?
      ids = []
      # get the ids
      files.each do |f|
        # -1 = district-precinct[-amendment]
        # -2 = district
        # -3 = election
        parts = f.split('/')
        election_id = parts[-3]
        district_id = parts[-2]
        precinct_id = parts[-1].gsub(/\d*-(\d*.\d*).*.jpg/, '\1')
        supplemental_documents_found = parts[-1].index('amendment').present?
        supplemental_document_count = supplemental_documents_found==true ? 1 : 0
        file_path = f.gsub(root, '')

        # see if there is already a record
        exists = ids.select{|x| x[:election_id] == election_id && x[:district_id] == district_id && x[:precinct_id] == precinct_id}.first
        if exists.present? && supplemental_documents_found == true
          # this is an amendendent, so update the count
          exists[:supplemental_documents_found] = true
          exists[:supplemental_document_count] += 1
          exists[:files] << file_path
        else
          ids << {
            election_id: election_id,
            district_id: district_id,
            precinct_id: precinct_id,
            supplemental_documents_found: supplemental_documents_found,
            supplemental_document_count: supplemental_document_count,
            files: [file_path]
          }
        end

      end

      if ids.present?
        DistrictPrecinct.transaction do
          client = ActiveRecord::Base.connection
          now = Time.now

          # remove anything that was there
          HasProtocol.delete_all

          puts "++++++++++ image count = #{ids.length}"

          # load all districts/precincts that exist
          sql = "insert into has_protocols (election_id, district_id, precinct_id) values "
          sql << ids.map{|x| "(#{x[:election_id]}, '#{x[:district_id]}', '#{x[:precinct_id]}')"}.uniq.join(", ")
          client.execute(sql)

          # update district precint table to mark these as existing
          sql = "update district_precincts as dp left join has_protocols as hp on
                  hp.election_id = dp.election_id and hp.district_id = dp.district_id and hp.precinct_id = dp.precinct_id
                  set dp.has_protocol = if(hp.id is null, 0, 1), dp.updated_at = '#{now}' "
          client.execute(sql)

          HasProtocol.delete_all

          # if a supplemental document has been found for a protocol that has already been entered, the protocol needs to be re-entered
          # -> mark the crowd data records as invalid and delete the analysis record.
          amend_ids = ids.select{|x| x[:supplemental_documents_found] == true}
          puts "++++++++++ image's with supplemental documents = #{amend_ids.length}"

          if amend_ids.length > 0
            # load all districts/precincts that have supplemental documents
            sql = "insert into has_protocols (election_id, district_id, precinct_id, supplemental_document_count) values "
            sql << amend_ids.map{|x| "(#{x[:election_id]}, '#{x[:district_id]}', '#{x[:precinct_id]}', #{x[:supplemental_document_count]})"}.uniq.join(", ")
            client.execute(sql)
          end

          # if district/precinct alreday had supplemental documents, but has new ones:
          # - update count
          sql = "select dp.election_id, dp.district_id, dp.precinct_id, hp.supplemental_document_count from district_precincts as dp
                inner join has_protocols as hp on
                  hp.election_id = dp.election_id and
                  hp.district_id = dp.district_id and
                  hp.precinct_id = dp.precinct_id and
                  hp.supplemental_document_count > dp.supplemental_document_count
                where dp.has_supplemental_documents = 1"
          has_update_supplemental_documents = client.select_all(sql)
          puts "++++++++++ found #{has_update_supplemental_documents.present? ? has_update_supplemental_documents.length : 0} amendments for precincts that ALREADY HAD an amendment"


          # if district/precinct did not have supplemental documents:
          # - update flag
          sql = "select dp.election_id, dp.district_id, dp.precinct_id, hp.supplemental_document_count from district_precincts as dp "
          sql << "inner join has_protocols as hp on hp.election_id = dp.election_id and hp.district_id = dp.district_id and hp.precinct_id = dp.precinct_id "
          sql << "where dp.has_supplemental_documents = 0"
          has_new_supplemental_documents = client.select_all(sql)
          puts "++++++++++ found #{has_new_supplemental_documents.present? ? has_new_supplemental_documents.length : 0} amendments for precincts that DID NOT HAVE amendments"

          if has_update_supplemental_documents.present? || has_new_supplemental_documents.present?
            puts "++++++++++ recording supplemental documents"
            # clear out temp table
            HasProtocol.delete_all
            election_ids = []

            # insert the records
            if has_update_supplemental_documents.present?
              sql = "insert into has_protocols (election_id, district_id, precinct_id, supplemental_document_count) values "
              sql << has_update_supplemental_documents.map{|x| "(#{x['election_id']}, '#{x['district_id']}', '#{x['precinct_id']}', #{x['supplemental_document_count']})"}.uniq.join(", ")
              client.execute(sql)

              election_ids << has_update_supplemental_documents.map{|x| x['election_id']}.uniq
            end
            if has_new_supplemental_documents.present?
              sql = "insert into has_protocols (election_id, district_id, precinct_id, supplemental_document_count) values "
              sql << has_new_supplemental_documents.map{|x| "(#{x['election_id']}, '#{x['district_id']}', '#{x['precinct_id']}', #{x['supplemental_document_count']})"}.uniq.join(", ")
              client.execute(sql)

              election_ids << has_update_supplemental_documents.map{|x| x['election_id']}.uniq
            end
            election_ids.flatten!.uniq!
            puts "++++++++++ election_ids = #{election_ids}"

            # mark flag
            sql = "update district_precincts as dp inner join has_protocols as hp on
                    hp.election_id = dp.election_id and hp.district_id = dp.district_id and hp.precinct_id = dp.precinct_id
                    set dp.has_supplemental_documents = 1, dp.supplemental_document_count = hp.supplemental_document_count, dp.is_validated = 0, dp.updated_at = '#{now}' "
            client.execute(sql)

            # mark crowd datum as invalid
            sql = "update crowd_data as cd inner join has_protocols as hp on
                  hp.election_id = cd.election_id and hp.district_id = cd.district_id and hp.precinct_id = cd.precinct_id
                  set cd.is_valid = 0, cd.updated_at = '#{now}' where cd.is_valid = 1"
            client.execute(sql)


            # delete analysis record
            elections = Election.where(id: election_ids)
            if elections.present?
              elections.each do |election|
                sql = "delete p from `#{@@analysis_db}`.`#{election.analysis_table_name} - raw` as p
                        inner join has_protocols as hp on
                        hp.district_id = p.district_id  COLLATE utf8_unicode_ci
                        and hp.precinct_id = p.precinct_id  COLLATE utf8_unicode_ci
                        where hp.election_id = #{election.id}"
                client.execute(sql)
              end
            end

            # now register the new documents
            all_files = ids.select{|x| x[:supplemental_documents_found] == true}.map{|x| x[:files]}.flatten
            all_files = all_files.select{|x| x.index('amendment').present?}
            existing_documents = SupplementalDocument.pluck(:file_path)
            # if existing documents exist, remove them from the list so they are not entered again
            if existing_documents.present?
              all_files = all_files - existing_documents
            end
            puts "++++++++++ need to create #{all_files.length} supplemental doc records"

            # if there are any files left, register them
            if all_files.present?
              all_files.each do |file|
                id = ids.select{|x| x[:files].include? file}.first
                if id.present?
                  dp = DistrictPrecinct.by_ids(id[:election_id], id[:district_id], id[:precinct_id]).first
                  if dp.present?
                    dp.supplemental_documents.create(file_path: file)
                  end
                end
              end
            end
          end
        end
      end
    end
  end


  #######################################
  ## METHODS

  # return the text labels for all the reasons being moderated
  def moderation_reason_text(sep=', ')
    text = []

    if self.moderation_reason.present?
      reasons = self.moderation_reason.index(',').nil? ? [self.moderation_reason] : self.moderation_reason.split(',')
      reasons.each do |reason|
        index = MODERATION_REASONS.values.index(reason.to_i)
        if index.present?
          text << I18n.t("root.cant_enter_help.tabs.#{MODERATION_REASONS.keys[index]}")
        end
      end
    end

    return text.join(sep)
  end

  def moderation_status_text
    text = ''

    self.moderation_status = 0 if self.moderation_status.nil?
    index = MODERATION_STATUS.values.index(self.moderation_status.to_i)
    if index.present?
      text = I18n.t("root.moderate.status.#{MODERATION_STATUS.keys[index]}")
    end

    return text
  end


  #######################################
  #######################################
  #######################################

  protected


  def self.format_number(number)
    ActionController::Base.helpers.number_with_delimiter(ActionController::Base.helpers.number_with_precision(number))
  end

  def self.format_percent(number)
    ActionController::Base.helpers.number_to_percentage(ActionController::Base.helpers.number_with_precision(number))
  end


  #format: [ {election_id => a, districts => [ { district_id => [ precinct_id, precinct_id,   ] } ] } ]
  def self.build_api_request(elections, data, all_districts=nil)
    records = []
    if elections.present? && data.present?
      elections.each do |election|
        e = {
          election_id: election.id,
          scraper_url_base: election.scraper_url_base,
          scraper_url_folder_to_images: election.scraper_url_folder_to_images,
          scraper_page_pattern: election.scraper_page_pattern,
          districts: [],
          district_decs: []
        }

        records << e

        district_ids = data.select{|x| x.election_id == election.id}.map{|x| x.district_id}.uniq

        if district_ids.present?
          district_ids.each do |district_id|
            district = Hash.new
            e[:districts] << district
            district[district_id] = []
            precinct_ids = data.select{|x| x.election_id == election.id && x.district_id == district_id}.map{|x| x.precinct_id}.uniq.sort

            if precinct_ids.present?
              district[district_id] << precinct_ids
              district[district_id].flatten!
            end

          end
        end

        # get dec #s for all districts
        if all_districts.present?
          district_ids = all_districts.select{|x| x.election_id == election.id}.map{|x| x.district_id}.uniq

          if district_ids.present?
            district_ids.each do |district_id|
              district = Hash.new
              e[:district_decs] << district
              district[district_id] = []
              dec_ids = all_districts.select{|x| x.election_id == election.id && x.district_id == district_id}.map{|x| x.precinct_id.split(election.district_precinct_separator).first}.uniq.sort

              if dec_ids.present?
                district[district_id] << dec_ids
                district[district_id].flatten!
              end
            end
          end
        end
      end
    end

    return records
  end

end
