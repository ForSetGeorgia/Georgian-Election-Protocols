class AddRunoffSettings < ActiveRecord::Migration
  def up
    election = Election.includes(:election_translations).where(election_translations: {name: '2017 Self-Governing City Mayor Runoff Election'}).first
    election.can_enter_data = true
    election.election_app_event_id = 56
    election.scraper_url_base = 'results.cec.gov.ge'
    election.scraper_url_folder_to_images = '/oqm/4/'
    election.scraper_page_pattern = 'oqmi_{id}.html'
    election.protocol_top_box_margin = '117'
    election.protocol_party_top_margin = '4'
    election.max_party_in_district = 12
    election.save

    election = Election.includes(:election_translations).where(election_translations: {name: '2017 Self-Governing Community Mayor Runoff Election'}).first
    election.can_enter_data = true
    election.election_app_event_id = 57
    election.scraper_url_base = 'results.cec.gov.ge'
    election.scraper_url_folder_to_images = '/oqm/10/'
    election.scraper_page_pattern = 'oqmi_{id}.html'
    election.protocol_top_box_margin = '114'
    election.protocol_party_top_margin = '4'
    election.max_party_in_district = 12
    election.save

  end

  def down
    puts "do nothing"
  end
end
