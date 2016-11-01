class RemoveFakeAmendments < ActiveRecord::Migration
  def up
    # there are protocols that indicate that they have supplemental documents but the files are bad
    # and after looking on cec website, there are no protocols.
    # so need to delete these records, and reset the sup doc flag
    files = [
      '/system/protocols/2/61/61-70.33_amendment_1.jpg',
      '/system/protocols/2/42/42-32.104_amendment_1.jpg',
      '/system/protocols/3/01/01-01.04_amendment_1.jpg',
      '/system/protocols/3/29/29-20.20_amendment_1.jpg',
      '/system/protocols/3/62/62-65.20_amendment_1.jpg',
      '/system/protocols/3/73/73-82.16_amendment_1.jpg'
    ]

    DistrictPrecinct.transaction do

      sup_docs = SupplementalDocument.where(file_path: files)
      if sup_docs.present?
        sup_docs.each do |sup_doc|
          dp = sup_doc.district_precinct
          DistrictPrecinct.redownload_protocol_and_documents(dp.election_id, dp.district_id, dp.precinct_id) if dp.present?
        end
      end

    end
  end

  def down
    puts "do nothing"
  end
end
