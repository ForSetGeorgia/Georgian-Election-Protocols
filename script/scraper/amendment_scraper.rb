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
start_time = Time.now
checkfile = "prot_scraper_check"
@logger_info = Logger.new("../../log/scraper_info.log")
@logger_error = Logger.new("../../log/scraper_error.log")

app_base_url = if !ARGV[0].nil? && ARGV[0].downcase == 'test'
  'http://localhost:3001'
else
  'https://protocols.electionsportal.ge'
end

app_get_uri = "/en/json/all_protocols"

protocol_dir = if !ARGV[0].nil? && ARGV[0].downcase == 'test'
  '/home/jason/projects/protocols/public/system/protocols'
else
  '/home/protocols/Protocols/shared/system/protocols'
end


# download images for a protocol
def download_protocol_images(page, district_dir, district_id, precinct_id)
  ##################
  # GET HTML PAGE
  ##################
  begin
    @logger_info.info("Retrieving: #{page}")
    agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Firefox" }
    html = agent.get(page).body
    @logger_info.info("Retrieved page: #{page}")
  rescue => e
    @logger_error.error("Unable to retrieve: #{page} | #{e}")
  end

  ##################
  # GET IMAGES
  ##################
  doc = Nokogiri::HTML(html)
  images = doc.css("img")
  links = images.map { |i| i['src']}
  amend_count = 1

  if links.length > 1
    links.each_with_index do |value,index|
      if index > 0
        img_uri = value.sub('../../','')
        img_url = "http://#{@url}/#{img_uri}"
        img_bname = "#{district_id}-#{precinct_id}"

        begin
          unless File.exists?("#{district_dir}#{img_bname}_amendment_#{amend_count}.jpg")
            @logger_info.info("Downloading amendment: #{img_bname}")
            open("#{district_dir}#{img_bname}_amendment_#{amend_count}.jpg", 'wb') do |pfile|
              puts "Downloading: #{district_dir}#{img_bname}_amendment_#{amend_count}.jpg"
              pfile << open(img_url).read
            end
            @logger_info.info("Downloaded amendment: #{img_bname}")
            amend_count += 1
            @amend_counter += 1
          end
        rescue => e
          @logger_error.error("Download failed: #{img_bname} | #{e}")
          next
        end
      end # if index
    end # links
  end

  sleep(0)
end


# check if scraper is already running
if File.exist?(protocol_dir + '/' + checkfile)
  @logger_info.info("Scraper already running.")
else
  FileUtils.touch(protocol_dir + '/' + checkfile)

  # get list of missing protocols via API
  begin
    @logger_info.info("Getting list of remaining precincts via API call.")
    elections = JSON.load(open(app_base_url + app_get_uri))
  rescue OpenURI::HTTPError => e
    @logger_error.error(e)
    FileUtils.rm(protocol_dir + checkfile)
    # Send email!!!
  end

  @logger_info.info("Got list of remaining precincts.")

  ##################
  # ELECTION LEVEL
  ##################
  elections.each do |election|

    @election_id = election['election_id']
    @url = election['scraper_url_base']
    @uri = election ['scraper_url_folder_to_images']
    @filename = election['scraper_page_pattern']
    @districts = election['districts']
    @is_parliamentary = election['is_parliamentary']
    @proto_counter = 0 # for counting how many protos downloaded / scrape
    @amend_counter = 0 # for counting how many protos downloaded / scrape

    # make election directory if it doesn't exist
    election_dir = "#{protocol_dir}/#{@election_id}/"
    Dir.mkdir(election_dir) unless File.exists?(election_dir)

    @districts.each do |district|

      ##################
      # DISTRICT LEVEL
      ##################
      district.each do |district_id, precinct_ids|

        # make district directory if it doesn't exist
        district_dir = "#{protocol_dir}/#{@election_id}/#{district_id}/"
        Dir.mkdir(district_dir) unless File.exists?(district_dir)

        ##################
        # PRECINCT LEVEL
        ##################
        # decs are used in parliamentary elections
        if @is_parliamentary && election['district_decs'].present?
          @decs = election['district_decs'].select { |d| d[district_id] }.first.values.flatten
        end

        precinct_ids.each do |precinct_id|
          # parliamentary elections have a special numbering system that has to be accounted for (i.e., xx.yy.xx)
          # all other elections are of the common format: xx_yy
          if @is_parliamentary
            @decs.each do |dec|
              id = "#{dec.to_i}_#{district_id}.#{precinct_id}"
              fname = @filename.sub('{id}', id)
              page = "http://#{@url}#{@uri}#{fname}"

              # download the images
              download_protocol_images(page, district_dir, district_id, precinct_id)
            end # @decs
          else
            id = "#{district_id}_#{precinct_id}"
            fname = @filename.sub('{id}', id)
            page = "http://#{@url}#{@uri}#{fname}"

            # download the images
            download_protocol_images(page, district_dir, district_id, precinct_id)
          end
        end # precincts
      end # district hash
      current_time = Time.now
      time_elapsed = (current_time - start_time)/60
      @logger_info.info("Amends Downloaded: #{@amend_counter}")
      @logger_info.info("Time elapsed: #{time_elapsed} minutes")
    end # districts
  end # elections


  end_time = Time.now
  duration =  (end_time - start_time)/60 # in minutes
  @logger_info.info("Scraper run time: #{duration} minutes")
  FileUtils.rm(protocol_dir + '/' + checkfile)
end # main if
