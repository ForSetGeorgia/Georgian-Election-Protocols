class AddSupDocDataToAnalysis < ActiveRecord::Migration

  def up
    start = Time.now
    dps = DistrictPrecinct.all
    dps.each_with_index do |dp, index|
      puts "updated #{index} out of #{dps.length} records so far" if index % 500 == 0
      dp.update_analysis_supplemental_document_data
    end
    puts "it took #{Time.now - start} seconds to do this"
  end

  def down
    puts 'do nothing'
  end
end
