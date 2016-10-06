class AddElectionFields < ActiveRecord::Migration
  def up
    add_column :elections, :max_party_in_district, :integer, default: 0
    add_column :elections, :protocol_top_box_margin, :integer, default: 0
    add_column :elections, :protocol_party_top_margin, :integer, default: 0

    major = Election.includes(:election_translations).where(election_translations: {name: '2012 Parliamentary - Majoritarian'}).first
    prop = Election.includes(:election_translations).where(election_translations: {name: '2012 Parliamentary - Party List'}).first

    if prop.present? && major.present?
      # get the 2012 major and add the max value
      major.max_party_in_district = DistrictParty.where(election_id: major.id).group(:district_id).count.values.max

      # for 2012 elections add top margin
      prop.protocol_top_box_margin = 117
      major.protocol_top_box_margin = 123

      # for 2012 party height
      prop.protocol_party_top_margin = 7
      major.protocol_party_top_margin = 8

      prop.save
      major.save
    else
      puts "!!!!!!!!!!!!!!!!!!!"
      puts "ERROR - COULD NOT FIND 2012 PROP AND/OR MAJOR ELECTIONS"
      puts "!!!!!!!!!!!!!!!!!!!"
    end
  end

  def down
    remove_column :elections, :max_party_in_district
    remove_column :elections, :protocol_top_box_margin
    remove_column :elections, :protocol_party_top_margin
  end
end
