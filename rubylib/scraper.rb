
# Scraper to download NSW Hansard XML files using API
# 
# In order to facilitate automatically downloading each day's hansard
# without having to manually download and save each day
# 
# This version of code hacked together by Alison Keen Dec 2016
#
# NSW Parliament Hansard API Docs are here: 
# 
# https://parliament-api-docs.readthedocs.io/en/latest/new-south-wales/
#
# Apologies for flagrant violation of coding conventions.

require 'scraperwiki'
require 'json'
require 'fileutils'

require_relative 'configuration'

# from Hansard server content-type is text/html, attachment is xml

$debug = FALSE
$csvoutput = FALSE
$sqloutput = FALSE

class JSONDownloader

  # The URLs to access the API... 

#  @jsonDownloadTocUrl = "https://hansardpublic.parliament.sa.gov.au/_vti_bin/Hansard/HansardData.svc/GetByDate"

  def initialize
    @total_found_transcripts = 0
    @total_missing_transcripts = 0
  end 

  def download_all_TOCs(year) 
  
    #Annual Index is a special case - different API URL  
    # NB annual_index_filename returned includes full path
    annual_index_filename = downloadAnnualIndex(year)

    get_each_toc_filename(annual_index_filename) 


      # then we read and load the JSON
      # and request each fragment for each day... 
#       downloadToc(nswph_toc_filename) 

      # then get the hash of fragments from each TOC file... 

        # and download each one. 

  end

  # Puts the raw, no-line-breaks JSON into a file and
  # returns the file name.
  def downloadAnnualIndex(year)

    @jsonDownloadYearURL = "https://api.parliament.nsw.gov.au/api/hansard/search/year/"
    
    warn 'nil year supplied?' if(year == NIL) 

    urlToLoad = @jsonDownloadYearURL + year.to_s
    filename = PIPEConf::JSON_INDEX_DIR + "#{year.to_s}_hansard.json"
    
    puts "downloading file #{filename}" if $debug  
    `curl --silent --output #{filename} "#{urlToLoad}"`
 
    filename # The output of the method. ruby doesn't use 'return'
  end

  # read JSON file and get toc filenames
  def get_each_toc_filename(annual_index_filename)

    #  Manual Download Link: 
    @toc_link = "https://api.parliament.nsw.gov.au/api/hansard/search/daily/tableofcontents/"

    @transcripts_found = 0
    @transcripts_missing = 0

    puts "Parsing annual index #{annual_index_filename}" if $debug
    rawJSON = File.read(annual_index_filename)
    
    parsedJSON = JSON.load rawJSON 


#    @outputfile << "\n<div class=\"col-sm-4\">"

    parsedJSON.each do |event| # for-each-date
      puts event.keys if $debug
      record_date =  event['date'].to_s

#      puts "Available for..." + record_date if $debug

      event['Events'].each do |record| # for each transcript on date
#        puts "\nEvent: " + record.to_s if $debug
        nswph_toc_filename = record['TocDocId'].to_s.strip
        nswph_chamber = record['Chamber'].to_s
   

        if !nswph_toc_filename.empty? then
          #Output is here: 

#            puts "\"#{nswph_toc_filename}\",\"#{record_date}\",\"#{nswph_chamber}\"" 
          downloaded_filename = PIPEConf::XML_TOC_DIR + nswph_toc_filename + ".xml"

          if ( File.exists?(downloaded_filename) ) then 
#            puts "#{downloaded_filename} already downloaded." if $debug

            @transcripts_found += 1

          else 
            @transcripts_missing += 1
            download_toc_file(nswph_toc_filename)

          end

        end

      end # end for-each-transcript-on-date block
      
    end # end for-each-date block

    if ( @transcripts_missing == 0 ) then
      @outputfile << "\n<h4> No Transcripts missing from "
      file_basename = File.basename(annual_index_filename, ".json")
      @outputfile << "#{file_basename} </h4>"
    end

#    @outputfile << "\n</div>" #end col-sm-4

    @total_missing_transcripts += @transcripts_missing
    @total_found_transcripts += @transcripts_found

    @transcripts_found #return number of transcripts found

  end
  # read JSON file and get toc filenames
  def download_toc_file(nswph_toc_filename)

    # TOC XML file download Link: 
    @toc_link = "https://api.parliament.nsw.gov.au/api/hansard/search/daily/tableofcontents/"

    downloaded_filename = PIPEConf::XML_TOC_DIR + nswph_toc_filename + ".xml"
    puts "Downloading: #{downloaded_filename}"

    if ( File.exists?(downloaded_filename) ) then 
      puts "#{downloaded_filename} already downloaded." if $debug

    else 
      puts "#{downloaded_filename} not found." if $debug
      toc_download_link = @toc_link + nswph_toc_filename
      `curl --silent --output #{downloaded_filename} "#{toc_download_link}"`
    end

  end

  def get_num_transcripts_found
    @total_found_transcripts
  end
 
  def get_num_transcripts_missing
    @total_missing_transcripts
  end


  def open_html_output_page()
    filename = "/var/www/pipeproject/#{PIPEConf::STATE}/missing_files.php"
    @outputfile = File.open(filename, "w")
    @outputfile << "\n<?php include \'../header.php\' ?>"
    @outputfile << "\n<div class=\"container\">"
    @outputfile << "\n<div class=\"row\">"
  end

  def close_html_output_page()
    @outputfile << "\n</div></div>"
    @outputfile << "\n<?php include \'../footer.php\' ?>"
    @outputfile.close
  end
    
end #end of JSONDownloader class
