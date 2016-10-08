#!/usr/bin/env ruby
# encoding: UTF-8

# scraper for protocol app

require 'logger'
require 'json'
require 'net/http'
require 'nokogiri'
require 'fileutils'
require 'open-uri'

# main variables

logger_info = Logger.new("../../log/scraper_info.log")
logger_error = Logger.new("../../log/scraper_error.log")

app_base_url = "https://protocols.jumpstart.ge"
app_get_uri = "/en/json/missing_protocols"
protocol_dir = "~/Protocols/shared/system/protocols/"

start_time = Time.now

# check if scraper is already running

checkfile = "prot_scraper_check"

if File.exist?(protocol_dir + '/' + checkfile)
  logger_info.info("Scraper already running.")
else
  FileUtils.touch(protocol_dir + checkfile)

  # get list of missing protocols via API
  begin
    logger_info.info("Getting list of remaining precincts via API call.")
    elections = JSON.load(open(app_base_url + app_get_uri))
  rescue OpenURI::HTTPError => e
    logger_error.error(e)
    FileUtils.rm(protocol_dir + checkfile)
    # Send email!!!
  end

  logger_info.info("Got list of remaining precincts.")

  ##################
  # ELECTION LEVEL
  ##################
  
  elections.each do |election|

    # make election directory if it doesn't exist
    edir = "#{protocol_dir}/#{@election_id}/"
    Dir.mkdir(edir) unless File.exists?(edir)

    @url = 'results2012.cec.gov.ge' # election['scraper_url_base']
    @uri = election ['scraper_url_folder_to_images']
    @filename = election['scraper_page_pattern']
    @districts = election['districts']

    @districts.each do |district|

      ##################
      # DISTRICT LEVEL
      ##################
      district.each do |did, precincts|

        fixed_did = did.to_i.to_s # remove leading zero

        # make district directory if it doesn't exist
        ddir = "#{protocol_dir}/#{@election_id}/#{did}/"
        Dir.mkdir(ddir) unless File.exists?(ddir)

        ##################
        # PRECINCT LEVEL
        ##################
        precincts.each do |precinct|

          fixed_precinct = precinct.split('.')[1].to_i.to_s

          fname = @filename.sub('{did}', fixed_did).sub('{pid}', fixed_precinct)
          page = "http://#{@url}#{@uri}#{fname}"

          begin
            logger_info.info("Checking: #{page}")
            response = Net::HTTP.get_response(URI(page))
          rescue
            logger_error.error("Error checking page: #{page}")
            next
          end

          ######################
          # CHECK HTML RESPONSE
          ######################
          if response.code.to_s == "200"
            logger_info.info("Page exists: #{page}")

            begin
              logger_info.info("Retrieving: #{page}")
              doc = Nokogiri::HTML(open(page))
            rescue
              logger_error.error("Unable to retrieve: #{page}")
              next
            end

            logger_info.info("Retrieved page: #{page}")

            ##################
            # GET IMAGES
            ##################
            images = doc.css("img")
            links = images.map { |i| i['src']}
            amend_count = 1

            links.each_with_index do |value,index|

              img_uri = value.sub('../','')
              img_url = "http://#{@url}/#{img_uri}"
              img_bname = "#{did}-#{precinct}"

              if index == 0
                begin
                  logger_info.info("Downloading protocol: #{img_bname}")
                  open("#{ddir}#{"#{img_bname}.jpg"}", 'wb') do |pfile|
                    pfile << open(img_url).read
                  end
                rescue
                  logger_error.error("Download failed: #{img_bname}")
                  next
                end
              else
                begin
                  logger_info.info("Downloading amendment: #{img_bname}")
                  open("#{ddir}#{img_bname}_amendment_#{amend_count}.jpg", 'wb') do |pfile|
                    pfile << open(img_url).read
                  end
                rescue
                  logger_error.error("Download failed: #{img_bname}")
                  next
                end
                amend_count += 1
              end # if response 200
            end # links

          else
            logger_error.error("Page doesn't exist: #{page}")
            next
          end

          sleep(1)
        end # precincts
      end # district hash
    end # districts
  end # elections


  end_time = Time.now
  duration =  (end_time - start_time)/60 # in minutes
  logger_info.info("Scraper run time: #{duration} minutes")
  FileUtils.rm(protocol_dir + checkfile)
end # main if
