#!/usr/bin/env ruby
# encoding: UTF-8

# scraper for protocol app

require 'logger'
require 'json'
require 'net/http'
require 'fileutils'
require 'open-uri'
require 'nokogiri'
require 'mechanize'

# main variables

logger_info = Logger.new("../../log/scraper_info.log")
logger_error = Logger.new("../../log/scraper_error.log")

app_base_url = "https://protocols.electionsportal.ge"
app_get_uri = "/en/json/all_protocols"

protocol_dir = "/home/protocols/Protocols/shared/system/protocols"
#protocol_dir = "/home/eric/projects/js/elections/Crowd-Source-Protocols/public/system/protocols"

start_time = Time.now

# check if scraper is already running

checkfile = "prot_scraper_check"

if File.exist?(protocol_dir + '/' + checkfile)
  logger_info.info("Scraper already running.")
else
  FileUtils.touch(protocol_dir + '/' + checkfile)

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

    @election_id = election['election_id']
    @url = election['scraper_url_base']
    @uri = election ['scraper_url_folder_to_images']
    @filename = election['scraper_page_pattern']
    @districts = election['districts']
    @proto_counter = 0 # for counting how many protos downloaded / scrape
    @amend_counter = 0 # for counting how many protos downloaded / scrape

    # make election directory if it doesn't exist
    edir = "#{protocol_dir}/#{@election_id}/"
    Dir.mkdir(edir) unless File.exists?(edir)

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
        @decs = election['district_decs'].select { |d| d[did] }.first.values.flatten # fix cec error of mismatched dec numbers

        precincts.each do |precinct|
          #dec = precinct.split('.')[0].to_i.to_s # dec
          fixed_precinct = precinct.split('.')[1].to_i.to_s # pid

          @decs.each do |dec|
            id = "#{dec.to_i}_#{did}.#{precinct}"

            fname = @filename.sub('{id}', id)
            page = "http://#{@url}#{@uri}#{fname}"


            ##################
            # GET HTML PAGE
            ##################
            begin
              logger_info.info("Retrieving: #{page}")
              agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Firefox" }
              html = agent.get(page).body
              logger_info.info("Retrieved page: #{page}")
            rescue => e
              logger_error.error("Unable to retrieve: #{page} | #{e}")
              next
            end

            ##################
            # GET IMAGES
            ##################
            doc = Nokogiri::HTML(html)
            images = doc.css("img")
            links = images.map { |i| i['src']}
            amend_count = 1

            links.each_with_index do |value,index|

              img_uri = value.sub('../../','')
              img_url = "http://#{@url}/#{img_uri}"
              img_bname = "#{did}-#{precinct}"


              if index > 0
                begin
                  unless File.exists?("#{ddir}#{img_bname}_amendment_#{amend_count}.jpg")
                    logger_info.info("Downloading amendment: #{img_bname}")
                    open("#{ddir}#{img_bname}_amendment_#{amend_count}.jpg", 'wb') do |pfile|
                      puts "Downloading: #{ddir}#{img_bname}_amendment_#{amend_count}.jpg"
                      pfile << open(img_url).read
                    end
                    logger_info.info("Downloaded amendment: #{img_bname}")
                    amend_count += 1
                    @amend_counter += 1
                  end
                rescue => e
                  logger_error.error("Download failed: #{img_bname} | #{e}")
                  next
                end
              end # unless protocol

            end # links

            sleep(0)
          end # @decs
        end # precincts
      end # district hash
      current_time = Time.now
      time_elapsed = (current_time - start_time)/60
      logger_info.info("Amends Downloaded: #{@amend_counter}")
      logger_info.info("Time elapsed: #{time_elapsed} minutes")
    end # districts
  end # elections


  end_time = Time.now
  duration =  (end_time - start_time)/60 # in minutes
  logger_info.info("Scraper run time: #{duration} minutes")
  FileUtils.rm(protocol_dir + '/' + checkfile)
end # main if
