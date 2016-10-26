class ChangeAmendmentFields < ActiveRecord::Migration
  def up
    puts '- updating protocol tables'
    remove_index :district_precincts, :has_amendment
    rename_column :district_precincts, :has_amendment, :has_supplemental_documents
    rename_column :district_precincts, :amendment_count, :supplemental_document_count
    add_index :district_precincts, :has_supplemental_documents

    add_column :district_precincts, :has_amendment, :boolean, default: false
    add_column :district_precincts, :has_explanatory_note, :boolean, default: false
    add_index :district_precincts, :has_amendment
    add_index :district_precincts, :has_explanatory_note

    rename_column :has_protocols, :amendment_count, :supplemental_document_count


    puts '- updating analysis tables'
    client = ActiveRecord::Base.connection

    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - raw` change `amendments_flag` `supplemental_documents_flag` INT(11)"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - raw` change `amendment_count` `supplemental_document_count` INT(11)"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - raw` ADD `amendment_flag` INT(11) NULL DEFAULT NULL after supplemental_document_count"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - raw` ADD `explanatory_note_flag` INT(11) NULL DEFAULT NULL after amendment_flag"
    client.execute(sql)

    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` change `amendments_flag` `supplemental_documents_flag` INT(11)"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` change `amendment_count` `supplemental_document_count` INT(11)"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` ADD `amendment_flag` INT(11) NULL DEFAULT NULL after supplemental_document_count"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` ADD `explanatory_note_flag` INT(11) NULL DEFAULT NULL after amendment_flag"
    client.execute(sql)

    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` change `amendments_flag` `supplemental_documents_flag` INT(11)"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` change `amendment_count` `supplemental_document_count` INT(11)"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` ADD `amendment_flag` INT(11) NULL DEFAULT NULL after supplemental_document_count"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` ADD `explanatory_note_flag` INT(11) NULL DEFAULT NULL after amendment_flag"
    client.execute(sql)

    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_major_rerun - raw` change `amendments_flag` `supplemental_documents_flag` INT(11)"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_major_rerun - raw` change `amendment_count` `supplemental_document_count` INT(11)"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_major_rerun - raw` ADD `amendment_flag` INT(11) NULL DEFAULT NULL after supplemental_document_count"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_major_rerun - raw` ADD `explanatory_note_flag` INT(11) NULL DEFAULT NULL after amendment_flag"
    client.execute(sql)

    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majr_runoff - raw` change `amendments_flag` `supplemental_documents_flag` INT(11)"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majr_runoff - raw` change `amendment_count` `supplemental_document_count` INT(11)"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majr_runoff - raw` ADD `amendment_flag` INT(11) NULL DEFAULT NULL after supplemental_document_count"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majr_runoff - raw` ADD `explanatory_note_flag` INT(11) NULL DEFAULT NULL after amendment_flag"
    client.execute(sql)


    puts '- recreating analysis views'
    Election.all.each do |election|
      election.create_analysis_views
    end

  end

  def down
    puts '- updating protocol tables'
    # remove_index :district_precincts, :has_amendment
    # remove_index :district_precincts, :has_explanatory_note
    # remove_column :district_precincts, :has_amendment
    # remove_column :district_precincts, :has_explanatory_note

    # remove_index :district_precincts, :has_supplemental_documents
    # rename_column :district_precincts, :has_supplemental_documents, :has_amendment
    # rename_column :district_precincts, :supplemental_document_count, :amendment_count
    # add_index :district_precincts, :has_amendment

    # rename_column :has_protocols, :supplemental_document_count, :amendment_count


    puts '- updating analysis tables'
    client = ActiveRecord::Base.connection

    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - raw` drop column `amendment_flag`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - raw` drop column `explanatory_note_flag`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - raw` change `supplemental_documents_flag` `amendments_flag`  INT(11)"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2013_presidential - raw` change `supplemental_document_count` `amendment_count` INT(11)"
    client.execute(sql)


    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` drop column `amendment_flag`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` drop column `explanatory_note_flag`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` change `supplemental_documents_flag` `amendments_flag`  INT(11)"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_party_list - raw` change `supplemental_document_count` `amendment_count` INT(11)"
    client.execute(sql)


    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` drop column `amendment_flag`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` drop column `explanatory_note_flag`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` change `supplemental_documents_flag` `amendments_flag`  INT(11)"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majoritarian - raw` change `supplemental_document_count` `amendment_count` INT(11)"
    client.execute(sql)


    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_major_rerun - raw` drop column `amendment_flag`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_major_rerun - raw` drop column `explanatory_note_flag`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_major_rerun - raw` change `supplemental_documents_flag` `amendments_flag`  INT(11)"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_major_rerun - raw` change `supplemental_document_count` `amendment_count` INT(11)"
    client.execute(sql)


    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majr_runoff - raw` drop column `amendment_flag`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majr_runoff - raw` drop column `explanatory_note_flag`"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majr_runoff - raw` change `supplemental_documents_flag` `amendments_flag`  INT(11)"
    client.execute(sql)
    sql = "ALTER TABLE `protocol_analysis`.`2016_parliamentary_majr_runoff - raw` change `supplemental_document_count` `amendment_count` INT(11)"
    client.execute(sql)


  end
end
