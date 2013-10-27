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

counter_max = 20

cec_base_url = "results2012.cec.gov.ge"
election = "prop"

app_base_url = "protocols.jumpstart.ge"
app_get_uri = "/en/json/missing_protocols"
app_post_uri = "/en/json/mark_found_protocols"
protocol_dir = "/root/protocols/"
#protocol_dir = "/home/eric/Desktop/cec_scraper/"
remote_server = "protocols@epsilon.jumpstart.ge"
remote_dir = "~/Protocols/shared/system/protocols/"


# methods

def remote_file_exists?(url)
  url = URI.parse(url)
  Net::HTTP.start(url.host, url.port) do |http|
    return http.head(url.request_uri).code == "200"
  end
end

# check if scraper is already running

start_time = Time.now
checkfile = "prot_scraper_check"

if File.exist?(protocol_dir + '/' + checkfile)
  puts "Scraper is already running."
else
  FileUtils.touch(protocol_dir + checkfile)
  
  # check if server is accessible

  check_target_server("http://" + cec_base_url)

  # get list of missing precincts

  file = Net::HTTP.get(app_base_url, app_get_uri)
  districts = JSON.parse(file)
  
  counter = 0 
  
  districts.each do |district|

    district_id = district["district_id"]
#    district_id = district
         
    # create protocol directory if it doesn't exist
    
    district_dir = protocol_dir + district_id.to_s
    Dir.mkdir(district_dir) unless File.exists?(district_dir)

    precincts = district["precincts"]
#    precincts = ["1", "2", "3", "4", "5", "7", "9", "10", "12", "14", "15", "16", "17", "18", "19", "20"]    
    precincts.each do |precinct|
    
      #precinct_id = precinct
      precinct_id = precinct["id"]
      
      cec_page_uri = "/#{election}/oqmi_" + 
                 district_id.to_s + "_" + 
                 precinct_id.to_s + 
                 ".html"
      
      # check if protocol exists on cec server
      
      response = Net::HTTP.get_response(URI("http://" + cec_base_url + cec_page_uri))
    
      if response.code.to_s == "200"
        puts "Page http://" + cec_base_url + cec_page_uri + " found."
        page = Net::HTTP.get(cec_base_url, cec_page_uri)
        page_contents = Nokogiri::HTML(page)
        
        # if protocol and/or amendment exists get protocol
        
        if page_contents.css("img").nil?
          puts "No images exist on #{cec_base_url + cec_page_uri}."
        else
          if page_contents.css("img")[0].attribute("src").nil?
            puts "No protocol image exists."
          else
            proto_exist = true
            puts "Protocol #{district_id}-#{precinct_id} image found."
            prot_image_uri = page_contents.css("img")[0].attribute("src").to_s.sub("..", "")
            prot_image_url = "http://" + cec_base_url + prot_image_uri
            prot_filename = district_id.to_s + "-" + precinct_id.to_s + ".jpg"
          end
          
          if page_contents.css("img")[1].nil?
            puts "No amended image exists."
          else
            amend_exist = true
            puts "*** Amended #{district_id}-#{precinct_id} image found. ***"
            amend_image_uri = page_contents.css("img")[1].attribute("src").to_s.sub("..", "")
            amend_image_url = "http://" + cec_base_url + amend_image_uri
            amend_filename = district_id.to_s + "-" + precinct_id.to_s + "-amended.jpg"
          end
          
          if remote_server_up?(prot_image_url)
          
            if proto_exist
              open("#{district_dir}/#{prot_filename}", 'wb') do |pfile|
                pfile << open(prot_image_url).read
              end # open file
              puts "Protocol #{district_id}-#{precinct_id} saved to local drive."
            
              # copy file to remote server
              puts "Copying protocol to application server."
              `scp #{district_dir}/#{prot_filename} #{remote_server}:#{remote_dir}#{district_id}`
              puts "Copied file to application server."
              counter += 1
            else
              puts "Protocol #{district_id}-#{precinct_id} image not found."
            end # proto_exist
            
            if amend_exist
              open("#{district_dir}/#{amend_filename}", 'wb') do |afile|
                afile << open(amend_image_url).read
              end # open file
              puts "Amended #{district_id}-#{precinct_id} saved to local drive."
            
              # copy file to remote server
              puts "Copying amended protocol to application server."
              `scp #{district_dir}/#{amend_filename} #{remote_server}:#{remote_dir}#{district_id}`
              puts "*** Copied file to application server. ***"
            else
              puts "Amended #{district_id}-#{precinct_id} image not found."
            end # amend_exists
            
          else
            puts "Remote server is not up."
          end # check if remote server is up
          
        end # no images found on page  
      
      else
        puts "#{district_id}-#{precinct_id} page not found."
      end # if page exists
    
    puts "Counter: #{counter}"
    break if counter > counter_max
    end # precincts loop

  break if counter > counter_max
  end # districts loop

  end_time = Time.now

  duration =  (end_time - start_time)/60 # in minutes
  puts "Scraper run time: #{duration} minutes"
  FileUtils.rm(protocol_dir + checkfile)
end
