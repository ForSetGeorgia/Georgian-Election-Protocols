class AddElectionScraperUrls < ActiveRecord::Migration
  def change
    add_column :elections, :scraper_url_base, :string
    add_column :elections, :scraper_url_folder_to_images, :string
    add_column :elections, :scraper_page_pattern, :string
  end
end
