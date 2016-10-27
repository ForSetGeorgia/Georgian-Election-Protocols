class CreateSupplementaryDocuments < ActiveRecord::Migration
  def up
    puts '- creating table'
    create_table :supplemental_documents do |t|
      t.integer :district_precinct_id
      t.string :file_path
      t.boolean :is_amendment, default: false
      t.boolean :is_explanatory_note, default: false
      t.boolean :is_annullment, default: false
      t.integer :categorized_by_user_id

      t.timestamps
    end
    add_index :supplemental_documents, :categorized_by_user_id
    add_index :supplemental_documents, :district_precinct_id
    add_index :supplemental_documents, :file_path
    add_index :supplemental_documents, [:is_amendment, :is_explanatory_note, :is_annullment], name: 'idx_sup_docs_flags'

    root = "#{Rails.root}/public"

    puts '- adding records'
    DistrictPrecinct.transaction do
      Election.pluck(:id).each do |election_id|
        puts '------------------------------'
        puts "election #{election_id}"
        puts '------------------------------'

        dps = DistrictPrecinct.by_election(election_id).with_supplemental_documents
        if dps.present?
          puts " - has #{dps.length} precincts with supporting documents"

          # for each district/precinct,
          # - see if amendment file exists
          #  - if yes, create new record
          #  - if no, update dp record
          dps.each do |dp|
            crowd = CrowdDatum.by_ids(election_id, dp.district_id, dp.precinct_id).first
            if crowd.present?
              has_documents = false
              documents = crowd.supplemental_document_image_paths
              if documents.present?
                found_all = true
                documents.each do |document|
                  if File.exists?(root + document)
                    # found document, create record
                    dp.supplemental_documents.create(file_path: document)
                  else
                    found_all = false
                  end
                end
                has_documents = found_all
              end

              # if the dp has documents, update how many
              # else if the dp actually does not have documents, update the flag
              # - 2013 protocols are not on file so do not reset the dp records for this election
              if election_id > 1
                if has_documents
                  dp.supplemental_document_count = dp.supplemental_documents.count
                  dp.save
                else
                  # puts "- #{dp.district_id}.#{dp.precinct_id} does not have amendments -> reseting values"
                  # dp.has_supplemental_documents = false
                  # dp.supplemental_document_count = 0
                  # dp.has_amendment = false
                  # dp.has_explanatory_note = false
                  # dp.save
                end
              end
            end
          end
        end
      end
    end

  end

  def down
    drop_table :supplemental_documents
  end
end
