#!/usr/bin/env ruby

# scraper for protocol app
# need to remove the sample methods for production server!!!

require 'json'
require 'net/http'
require 'nokogiri'
require 'fileutils'
require 'open-uri'	
require './vpn_switcher.rb'

# main variables

app_base_url = "dev-protocols.jumpstart.ge"
app_get_uri = "/en/json/missing_protocols"
app_post_uri = "/en/json/mark_found_protocols"
protocol_dir = "/home/eric/Desktop/cec_scraper/"
cec_base_url = "results2012.cec.gov.ge"
election = "major"

# methods

def remote_file_exists?(url)
  url = URI.parse(url)
  Net::HTTP.start(url.host, url.port) do |http|
    return http.head(url.request_uri).code == "200"
  end
end

def remote_server_up?(server, port=80)
  http = Net::HTTP.start(server, port, {open_timeout: 5, read_timeout: 5})
  response = http.head("/")
  response.code == "200"
rescue Timeout::Error, SocketError
  false
end

# check if server is accessible

check_target_server("http://" + cec_base_url)

# get list of missing precincts

file = Net::HTTP.get(app_base_url, app_get_uri)
districts = JSON.parse(file).sample(10)

districts.each do |district|
  district_id = district["district_id"]
   
  # create protocol directory if it doesn't exist
  
  district_dir = protocol_dir + district_id.to_s
  Dir.mkdir(district_dir) unless File.exists?(district_dir)

  precincts = district["precincts"].sample(5)
  
  precincts.each do |precinct|
    precinct_id = precinct["id"]
    
    cec_page_uri = "/#{election}/oqmi_" + 
               district_id.to_s + "_" + 
               precinct_id.to_s + 
               ".html"
    
    # check if protocol exists on cec server
    
    response = Net::HTTP.get_response(URI("http://" + cec_base_url + cec_page_uri))
  
    if response.code.to_s == "200"
      puts "Page found."
      page = Net::HTTP.get(cec_base_url, cec_page_uri)
      page_contents = Nokogiri::HTML(page)
      
      # if protocol exists get protocol
      
      unless page_contents.css("img")[0].attribute("src").nil?
        puts "#{district_id}-#{precinct_id} image found"
        image_uri = page_contents.css("img")[0].attribute("src").to_s.sub("..", "")
        image_url = "http://" + cec_base_url + image_uri
        filename = district_id.to_s + "-" + precinct_id.to_s + ".jpg"
        
        if remote_file_exists?(image_url)
          open("#{district_dir}/#{filename}", 'wb') do |file|
            file << open(image_url).read
          end # open file
          puts "#{district_id}-#{precinct_id} saved to drive."
          
          # update array so that found = true
          precinct["found"] = true
        else
          puts "#{district_id}-#{precinct_id} image not found."
        end
      else
        puts "#{district_id}-#{precinct_id} image not found."
      end # if image exists
    else
      puts "#{district_id}-#{precinct_id} page not found."
    end # if page exists
    
  end # precincts loop

end # districts loop

data = districts.to_json
uri = URI("http://" + app_base_url + app_post_uri)

res = Net::HTTP.post_form(uri, 'data' => data)


