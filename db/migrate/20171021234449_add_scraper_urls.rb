class AddScraperUrls < ActiveRecord::Migration
  def up
    election = Election.includes(:election_translations).where(election_translations: {name: '2017 Local Election - Party List'}).first
    election.scraper_url_base = 'results.cec.gov.ge'
    election.scraper_url_folder_to_images = '/oqm/1/'
    election.scraper_page_pattern = 'oqmi_{id}.html'
    election.protocol_top_box_margin = '95'
    election.protocol_party_top_margin = '4'
    election.save

    election = Election.includes(:election_translations).where(election_translations: {name: '2017 Mayor Election'}).first
    election.scraper_url_base = 'results.cec.gov.ge'
    election.scraper_url_folder_to_images = '/oqm/4/'
    election.scraper_page_pattern = 'oqmi_{id}.html'
    election.protocol_top_box_margin = '104'
    election.protocol_party_top_margin = '4'
    election.save

    election = Election.includes(:election_translations).where(election_translations: {name: '2017 Local Election - Majoritarian'}).first
    election.scraper_url_base = 'results.cec.gov.ge'
    election.scraper_url_folder_to_images = '/oqm/2/'
    election.scraper_page_pattern = 'oqmi_{id}.html'
    election.protocol_top_box_margin = '102'
    election.protocol_party_top_margin = '4'
    election.save

    election = Election.includes(:election_translations).where(election_translations: {name: '2017 Governor Election'}).first
    election.scraper_url_base = 'results.cec.gov.ge'
    election.scraper_url_folder_to_images = '/oqm/10/'
    election.scraper_page_pattern = 'oqmi_{id}.html'
    election.protocol_top_box_margin = '97'
    election.protocol_party_top_margin = '5'
    election.save
  end

  def down
    puts "do nothing"
  end
end
