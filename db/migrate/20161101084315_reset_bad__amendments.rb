class ResetBadAmendments < ActiveRecord::Migration
  def up
    # there are protocols with bad amendment images that need to be redownloaded
    files = [
    '/system/protocols/2/16/16-08.54_amendment_1.jpg',
    '/system/protocols/2/36/36-22.62_amendment_2.jpg',
    '/system/protocols/2/39/39-30.28_amendment_1.jpg',
    '/system/protocols/2/51/51-48.30_amendment_2.jpg',
    '/system/protocols/3/01/01-01.07_amendment_1.jpg',
    '/system/protocols/3/01/01-01.11_amendment_1.jpg',
    '/system/protocols/3/01/01-01.13_amendment_1.jpg',
    '/system/protocols/3/01/01-01.14_amendment_1.jpg',
    '/system/protocols/3/01/01-01.19_amendment_1.jpg',
    '/system/protocols/3/01/01-01.23_amendment_1.jpg',
    '/system/protocols/3/01/01-01.32_amendment_1.jpg',
    '/system/protocols/3/39/39-30.28_amendment_1.jpg',
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
