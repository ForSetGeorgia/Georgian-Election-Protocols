class Update2016MajorArams < ActiveRecord::Migration
  def up
    election = Election.includes(:election_translations).where(election_translations: {name: '2016 Parliamentary - Majoritarian'}).first
    election.can_enter_data = true
    election.scraper_url_folder_to_images = '/oqm/6/'
    election.scraper_page_pattern = 'oqmi_{id}.html'
    election.protocol_top_box_margin = '114'
    election.protocol_party_top_margin = '2.5'
    election.save
  end

  def down
    puts "do nothing!"
  end
end
