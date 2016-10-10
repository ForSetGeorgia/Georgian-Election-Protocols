class AddHasAmendCounter < ActiveRecord::Migration
  def up
    add_column :district_precincts, :amendment_count, :integer, length: 3, default: 0
    add_column :has_protocols, :amendment_count, :integer, length: 3, default: 0


    # get all amendments
    # -
    path = "#{Rails.root}/public/system/protocols/**/*_amendment_*.jpg"
    amendments = Dir.glob(path)

    if amendments.present?
      puts "there are #{amendments.length} amendments"

      ids = []

      # the path is in the following format:
      # "#{Rails.root}/public/system/protocols/#{election_id}/#{district_id}/#{district_id}-#{precinct_id}_amendment_*.jpg
      amendments.each do |file|
        file_parts = file.split('/')
        # pull out the ids
        h = Hash.new
        h[:election_id] = file_parts[-3]
        h[:district_id] = file_parts[-2]
        h[:precinct_id] = file_parts[-1].gsub(/\d*-(\d*.\d*)_amendment_\d*.jpg/, '\1')

        # if the hash already exists, increase the count, else start it
        exists = ids.select{|x| x[:election_id] == h[:election_id] && x[:district_id] == h[:district_id] && x[:precinct_id] == h[:precinct_id]}.first
        if exists.present?
          exists[:count] += 1
        else
          h[:count] = 1
          ids << h
        end
      end

      puts "there are #{ids.length} district/precincts with amendments!"

      # update the records with the count
      puts "adding counts to records"
      ids.each do |id|
        DistrictPrecinct.by_ids(id[:election_id], id[:district_id], id[:precinct_id]).update_all(amendment_count: id[:count])
      end
    end
  end

  def down
    remove_column :district_precincts, :amendment_count
    remove_column :has_protocols, :amendment_count
  end
end
