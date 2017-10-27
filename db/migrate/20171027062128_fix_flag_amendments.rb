class FixFlagAmendments < ActiveRecord::Migration
  def up
    # the DistrictPrecinct.new_image_search had a bug in getting the precinct id from the file name
    # when the file was for an amendment - this caused no amendments to be loaded into the system
    # this script will flag all precincts that have amendments
    # and only the precincts where the amendment was downloaded at a later time will have their data reset

    election_ids = Election.can_enter.pluck(:id)

    if election_ids.present?
      root = "#{Rails.root}/public"
      files = []
      election_ids.each do |election_id|
        files << Dir.glob("#{root}/system/protocols/#{election_id}/**/*.jpg")
      end
      files.flatten!
      puts "==> there are #{files.length} protocol images"
      if files.present?
        amends = files.select{|x| !x.index('amendment').nil?};nil

        reenter = []
        amends.each_with_index do |amend, i|
          puts "process #{i} so far" if i%500 == 0
          idx_amend = files.index{|x| x == amend}
          if !idx_amend.nil?
            idx_protocol = files.index{|x| x == amend.gsub("_amendment_1", "")}
            if !idx_protocol.nil?
              if (File.ctime(files[idx_amend]) - File.ctime(files[idx_protocol])) > 120
                reenter << files[idx_amend]
              end
            end
          end
        end
        puts "==> there are #{amends.length} amendment images; of which #{reenter.length} must be re-entered"

        ids = []
        # get the ids
        files.each do |f|
          # -1 = district-precinct[-amendment]
          # -2 = district
          # -3 = election
          parts = f.split('/')
          election_id = parts[-3]
          district_id = parts[-2]
          precinct_id = parts[-1].gsub(/\d*-(\d*\.*\d*).*.jpg/, '\1')
          supplemental_documents_found = parts[-1].index('amendment').present?
          supplemental_document_count = supplemental_documents_found==true ? 1 : 0
          need_to_reenter = reenter.index(f).present? && supplemental_documents_found
          file_path = f.gsub(root, '')

          # see if there is already a record
          exists = ids.select{|x| x[:election_id] == election_id && x[:district_id] == district_id && x[:precinct_id] == precinct_id}.first
          if exists.present? && supplemental_documents_found == true
            # this is an amendendent, so update the count
            exists[:supplemental_documents_found] = true
            exists[:supplemental_document_count] += 1
            exists[:files] << file_path
            if exists[:need_to_reenter] == false
              exists[:need_to_reenter] = need_to_reenter
            end
          else
            ids << {
              election_id: election_id,
              district_id: district_id,
              precinct_id: precinct_id,
              supplemental_documents_found: supplemental_documents_found,
              supplemental_document_count: supplemental_document_count,
              files: [file_path],
              need_to_reenter: need_to_reenter
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
            puts "=============================================="

            #######################################
            #######################################
            #######################################
            # if supplemental document exists and does not need the protocol to be re-entered,
            # update the district precinct table and the raw table
            amend_ids = ids.select{|x| x[:supplemental_documents_found] == true && x[:need_to_reenter] == false}
            puts "++++++++++ image's with supplemental documents = #{amend_ids.length} that do not need to be re-entered"
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

              # mark flag in district precinct
              sql = "update district_precincts as dp inner join has_protocols as hp on
                      hp.election_id = dp.election_id and hp.district_id = dp.district_id and hp.precinct_id = dp.precinct_id
                      set dp.has_supplemental_documents = 1, dp.supplemental_document_count = hp.supplemental_document_count, dp.updated_at = '#{now}' "
              client.execute(sql)

              # mark flag in raw table
              sql = "select dp.id from district_precincts as dp "
              sql << "inner join has_protocols as hp on hp.election_id = dp.election_id and hp.district_id = dp.district_id and hp.precinct_id = dp.precinct_id "
              dp_ids = client.select_all(sql)
              if dp_ids.present?
                dps = DistrictPrecinct.where(id: dp_ids.map{|x| x['id']})
                puts "++++++++++ updating raw analytic rows for #{dps.length} district/precincts"
                dps.each do |dp|
                  dp.update_analysis_supplemental_document_data
                end
              end

              # now register the new documents
              all_files = amend_ids.map{|x| x[:files]}.flatten
              all_files = all_files.select{|x| x.index('amendment').present?}
              existing_documents = SupplementalDocument.can_enter_elections.pluck(:file_path)
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



            HasProtocol.delete_all
            puts "=============================================="



            #######################################
            #######################################
            #######################################
            # if a supplemental document has been found for a protocol that has already been entered, the protocol needs to be re-entered
            # -> mark the crowd data records as invalid and delete the analysis record.
            amend_ids = ids.select{|x| x[:supplemental_documents_found] == true && x[:need_to_reenter] == true}
            puts "++++++++++ image's with supplemental documents = #{amend_ids.length} that do need to be re-entered"

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
              all_files = amend_ids.map{|x| x[:files]}.flatten
              all_files = all_files.select{|x| x.index('amendment').present?}
              existing_documents = SupplementalDocument.can_enter_elections.pluck(:file_path)
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
  end

  def down
    puts "do nothing"
  end
end
