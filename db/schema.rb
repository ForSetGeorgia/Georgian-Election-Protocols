# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20161003191155) do

  create_table "2012_parliamentary_majoritarian - country", :id => false, :force => true do |t|
    t.decimal "possible voters",                                              :precision => 32, :scale => 0
    t.decimal "total ballots cast",                                           :precision => 32, :scale => 0
    t.decimal "total valid ballots cast",                                     :precision => 32, :scale => 0
    t.decimal "num invalid ballots from 0-1%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 1-3%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 3-5%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots >5%",                                      :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "percent voters voting",                                        :precision => 39, :scale => 4
    t.decimal "num precincts logic fail",                                     :precision => 32, :scale => 0
    t.decimal "percent precincts logic fail",                                 :precision => 39, :scale => 4
    t.decimal "avg precinct logic fail difference",                           :precision => 36, :scale => 4
    t.decimal "num precincts more ballots than votes",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more ballots than votes",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more ballots than votes",              :precision => 36, :scale => 4
    t.decimal "num precincts more votes than ballots",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more votes than ballots",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more votes than ballots",              :precision => 36, :scale => 4
    t.decimal "votes 8-12",                                                   :precision => 32, :scale => 0
    t.decimal "votes 12-17",                                                  :precision => 33, :scale => 0
    t.decimal "votes 17-20",                                                  :precision => 33, :scale => 0
    t.decimal "avg votes/precinct 8-12",                                      :precision => 36, :scale => 4
    t.decimal "avg votes/precinct 12-17",                                     :precision => 37, :scale => 4
    t.decimal "avg votes/precinct 17-20",                                     :precision => 37, :scale => 4
    t.decimal "vpm 8-12",                                                     :precision => 36, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 37, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 37, :scale => 4
    t.decimal "avg vpm/precinct 8-12",                                        :precision => 40, :scale => 8
    t.decimal "avg vpm/precinct 12-17",                                       :precision => 41, :scale => 8
    t.decimal "avg vpm/precinct 17-20",                                       :precision => 41, :scale => 8
    t.decimal "num precincts vpm 8-12 > 2",                                   :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 12-17 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 17-20 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm > 2",                                        :precision => 44, :scale => 0, :default => 0, :null => false
    t.decimal "num_precincts_possible",                                       :precision => 32, :scale => 0
    t.integer "num_precincts_reported_number",                   :limit => 8,                                :default => 0, :null => false
    t.decimal "num_precincts_reported_percent",                               :precision => 27, :scale => 4
    t.decimal "1 - Free Georgia count",                                       :precision => 32, :scale => 0
    t.decimal "1 - Free Georgia",                                             :precision => 39, :scale => 4
    t.decimal "4 - National Democratic Party of Georgia count",               :precision => 32, :scale => 0
    t.decimal "4 - National Democratic Party of Georgia",                     :precision => 39, :scale => 4
    t.decimal "5 - United National Movement count",                           :precision => 32, :scale => 0
    t.decimal "5 - United National Movement",                                 :precision => 39, :scale => 4
    t.decimal "9 - Movement for Fair Georgia count",                          :precision => 32, :scale => 0
    t.decimal "9 - Movement for Fair Georgia",                                :precision => 39, :scale => 4
    t.decimal "10 - Christian-Democratic Movement count",                     :precision => 32, :scale => 0
    t.decimal "10 - Christian-Democratic Movement",                           :precision => 39, :scale => 4
    t.decimal "17 - Public Movement count",                                   :precision => 32, :scale => 0
    t.decimal "17 - Public Movement",                                         :precision => 39, :scale => 4
    t.decimal "19 - Freedom Party count",                                     :precision => 32, :scale => 0
    t.decimal "19 - Freedom Party",                                           :precision => 39, :scale => 4
    t.decimal "23 - Georgian Group count",                                    :precision => 32, :scale => 0
    t.decimal "23 - Georgian Group",                                          :precision => 39, :scale => 4
    t.decimal "24 - New Rights count",                                        :precision => 32, :scale => 0
    t.decimal "24 - New Rights",                                              :precision => 39, :scale => 4
    t.decimal "26 - People's Party count",                                    :precision => 32, :scale => 0
    t.decimal "26 - People's Party",                                          :precision => 39, :scale => 4
    t.decimal "30 - Merab Kostava Society count",                             :precision => 32, :scale => 0
    t.decimal "30 - Merab Kostava Society",                                   :precision => 39, :scale => 4
    t.decimal "35 - Future Georgia count",                                    :precision => 32, :scale => 0
    t.decimal "35 - Future Georgia",                                          :precision => 39, :scale => 4
    t.decimal "36 - Labour Council of Georgia count",                         :precision => 32, :scale => 0
    t.decimal "36 - Labour Council of Georgia",                               :precision => 39, :scale => 4
    t.decimal "38 - Labour count",                                            :precision => 32, :scale => 0
    t.decimal "38 - Labour",                                                  :precision => 39, :scale => 4
    t.decimal "40 - Sportsman's Union count",                                 :precision => 32, :scale => 0
    t.decimal "40 - Sportsman's Union",                                       :precision => 39, :scale => 4
    t.decimal "41 - Georgian Dream count",                                    :precision => 32, :scale => 0
    t.decimal "41 - Georgian Dream",                                          :precision => 39, :scale => 4
  end

  create_table "2012_parliamentary_majoritarian - csv", :id => false, :force => true do |t|
    t.string  "shape",                                                       :limit => 16,                                :default => "", :null => false
    t.string  "common_id"
    t.string  "common_name"
    t.decimal "Total Voter Turnout (#)",                                                   :precision => 32, :scale => 0
    t.decimal "Total Voter Turnout (%)",                                                   :precision => 39, :scale => 4
    t.decimal "Number of Precincts with Invalid Ballots from 0-1%",                        :precision => 42, :scale => 0
    t.decimal "Number of Precincts with Invalid Ballots from 1-3%",                        :precision => 42, :scale => 0
    t.decimal "Number of Precincts with Invalid Ballots from 3-5%",                        :precision => 42, :scale => 0
    t.decimal "Number of Precincts with Invalid Ballots > 5%",                             :precision => 42, :scale => 0
    t.decimal "Invalid Ballots (%)",                                                       :precision => 17, :scale => 4
    t.decimal "Precincts with More Ballots Than Votes (#)",                                :precision => 32, :scale => 0
    t.decimal "Precincts with More Ballots Than Votes (%)",                                :precision => 39, :scale => 4
    t.decimal "More Ballots Than Votes (Average)",                                         :precision => 36, :scale => 4
    t.integer "More Ballots Than Votes (#)"
    t.decimal "Precincts with More Votes than Ballots (#)",                                :precision => 32, :scale => 0
    t.decimal "Precincts with More Votes than Ballots (%)",                                :precision => 39, :scale => 4
    t.decimal "More Votes than Ballots (Average)",                                         :precision => 36, :scale => 4
    t.integer "More Votes than Ballots (#)"
    t.decimal "Average votes per minute (08:00-12:00)",                                    :precision => 14, :scale => 4
    t.decimal "Average votes per minute (12:00-17:00)",                                    :precision => 15, :scale => 4
    t.decimal "Average votes per minute (17:00-20:00)",                                    :precision => 15, :scale => 4
    t.decimal "Number of Precincts with votes per minute > 2 (08:00-12:00)",               :precision => 42, :scale => 0
    t.decimal "Number of Precincts with votes per minute > 2 (12:00-17:00)",               :precision => 42, :scale => 0
    t.decimal "Number of Precincts with votes per minute > 2 (17:00-20:00)",               :precision => 42, :scale => 0
    t.decimal "Number of Precincts with votes per minute > 2",                             :precision => 44, :scale => 0
    t.integer "Precincts Reported (#)",                                      :limit => 8
    t.decimal "Precincts Reported (%)",                                                    :precision => 27, :scale => 4
    t.decimal "Free Georgia",                                                              :precision => 39, :scale => 4
    t.decimal "National Democratic Party of Georgia",                                      :precision => 39, :scale => 4
    t.decimal "United National Movement",                                                  :precision => 39, :scale => 4
    t.decimal "Movement for Fair Georgia",                                                 :precision => 39, :scale => 4
    t.decimal "Christian-Democratic Movement",                                             :precision => 39, :scale => 4
    t.decimal "Public Movement",                                                           :precision => 39, :scale => 4
    t.decimal "Freedom Party",                                                             :precision => 39, :scale => 4
    t.decimal "Georgian Group",                                                            :precision => 39, :scale => 4
    t.decimal "New Rights",                                                                :precision => 39, :scale => 4
    t.decimal "People's Party",                                                            :precision => 39, :scale => 4
    t.decimal "Merab Kostava Society",                                                     :precision => 39, :scale => 4
    t.decimal "Future Georgia",                                                            :precision => 39, :scale => 4
    t.decimal "Labour Council of Georgia",                                                 :precision => 39, :scale => 4
    t.decimal "Labour",                                                                    :precision => 39, :scale => 4
    t.decimal "Sportsman's Union",                                                         :precision => 39, :scale => 4
    t.decimal "Georgian Dream",                                                            :precision => 39, :scale => 4
  end

  create_table "2012_parliamentary_majoritarian - district", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id",                                     :limit => 8
    t.string  "district_Name"
    t.decimal "possible voters",                                              :precision => 32, :scale => 0
    t.decimal "total ballots cast",                                           :precision => 32, :scale => 0
    t.decimal "total valid ballots cast",                                     :precision => 32, :scale => 0
    t.decimal "num invalid ballots from 0-1%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 1-3%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 3-5%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots >5%",                                      :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "percent voters voting",                                        :precision => 39, :scale => 4
    t.decimal "num precincts logic fail",                                     :precision => 32, :scale => 0
    t.decimal "percent precincts logic fail",                                 :precision => 39, :scale => 4
    t.decimal "avg precinct logic fail difference",                           :precision => 36, :scale => 4
    t.decimal "num precincts more ballots than votes",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more ballots than votes",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more ballots than votes",              :precision => 36, :scale => 4
    t.decimal "num precincts more votes than ballots",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more votes than ballots",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more votes than ballots",              :precision => 36, :scale => 4
    t.decimal "votes 8-12",                                                   :precision => 32, :scale => 0
    t.decimal "votes 12-17",                                                  :precision => 33, :scale => 0
    t.decimal "votes 17-20",                                                  :precision => 33, :scale => 0
    t.decimal "avg votes/precinct 8-12",                                      :precision => 36, :scale => 4
    t.decimal "avg votes/precinct 12-17",                                     :precision => 37, :scale => 4
    t.decimal "avg votes/precinct 17-20",                                     :precision => 37, :scale => 4
    t.decimal "vpm 8-12",                                                     :precision => 36, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 37, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 37, :scale => 4
    t.decimal "avg vpm/precinct 8-12",                                        :precision => 40, :scale => 8
    t.decimal "avg vpm/precinct 12-17",                                       :precision => 41, :scale => 8
    t.decimal "avg vpm/precinct 17-20",                                       :precision => 41, :scale => 8
    t.decimal "num precincts vpm 8-12 > 2",                                   :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 12-17 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 17-20 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm > 2",                                        :precision => 44, :scale => 0, :default => 0, :null => false
    t.decimal "num_precincts_possible",                                       :precision => 32, :scale => 0
    t.integer "num_precincts_reported_number",                   :limit => 8,                                :default => 0, :null => false
    t.decimal "num_precincts_reported_percent",                               :precision => 27, :scale => 4
    t.decimal "1 - Free Georgia count",                                       :precision => 32, :scale => 0
    t.decimal "1 - Free Georgia",                                             :precision => 39, :scale => 4
    t.decimal "4 - National Democratic Party of Georgia count",               :precision => 32, :scale => 0
    t.decimal "4 - National Democratic Party of Georgia",                     :precision => 39, :scale => 4
    t.decimal "5 - United National Movement count",                           :precision => 32, :scale => 0
    t.decimal "5 - United National Movement",                                 :precision => 39, :scale => 4
    t.decimal "9 - Movement for Fair Georgia count",                          :precision => 32, :scale => 0
    t.decimal "9 - Movement for Fair Georgia",                                :precision => 39, :scale => 4
    t.decimal "10 - Christian-Democratic Movement count",                     :precision => 32, :scale => 0
    t.decimal "10 - Christian-Democratic Movement",                           :precision => 39, :scale => 4
    t.decimal "17 - Public Movement count",                                   :precision => 32, :scale => 0
    t.decimal "17 - Public Movement",                                         :precision => 39, :scale => 4
    t.decimal "19 - Freedom Party count",                                     :precision => 32, :scale => 0
    t.decimal "19 - Freedom Party",                                           :precision => 39, :scale => 4
    t.decimal "23 - Georgian Group count",                                    :precision => 32, :scale => 0
    t.decimal "23 - Georgian Group",                                          :precision => 39, :scale => 4
    t.decimal "24 - New Rights count",                                        :precision => 32, :scale => 0
    t.decimal "24 - New Rights",                                              :precision => 39, :scale => 4
    t.decimal "26 - People's Party count",                                    :precision => 32, :scale => 0
    t.decimal "26 - People's Party",                                          :precision => 39, :scale => 4
    t.decimal "30 - Merab Kostava Society count",                             :precision => 32, :scale => 0
    t.decimal "30 - Merab Kostava Society",                                   :precision => 39, :scale => 4
    t.decimal "35 - Future Georgia count",                                    :precision => 32, :scale => 0
    t.decimal "35 - Future Georgia",                                          :precision => 39, :scale => 4
    t.decimal "36 - Labour Council of Georgia count",                         :precision => 32, :scale => 0
    t.decimal "36 - Labour Council of Georgia",                               :precision => 39, :scale => 4
    t.decimal "38 - Labour count",                                            :precision => 32, :scale => 0
    t.decimal "38 - Labour",                                                  :precision => 39, :scale => 4
    t.decimal "40 - Sportsman's Union count",                                 :precision => 32, :scale => 0
    t.decimal "40 - Sportsman's Union",                                       :precision => 39, :scale => 4
    t.decimal "41 - Georgian Dream count",                                    :precision => 32, :scale => 0
    t.decimal "41 - Georgian Dream",                                          :precision => 39, :scale => 4
  end

  create_table "2012_parliamentary_majoritarian - invalid ballots 0-1", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "num_invalid_ballots", :limit => 8, :default => 0, :null => false
  end

  create_table "2012_parliamentary_majoritarian - invalid ballots 1-3", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "num_invalid_ballots", :limit => 8, :default => 0, :null => false
  end

  create_table "2012_parliamentary_majoritarian - invalid ballots 3-5", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "num_invalid_ballots", :limit => 8, :default => 0, :null => false
  end

  create_table "2012_parliamentary_majoritarian - invalid ballots >5", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "num_invalid_ballots", :limit => 8, :default => 0, :null => false
  end

  create_table "2012_parliamentary_majoritarian - precinct", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.string  "district_Name"
    t.integer "precinct_id"
    t.string  "precinct_name",                                  :limit => 23
    t.integer "possible voters"
    t.integer "total ballots cast"
    t.integer "total valid ballots cast"
    t.decimal "percent invalid ballots",                                      :precision => 17, :scale => 4
    t.decimal "percent voters voting",                                        :precision => 17, :scale => 4
    t.integer "logic_check_fail"
    t.integer "logic_check_difference"
    t.integer "more_ballots_than_votes_flag"
    t.integer "more_ballots_than_votes"
    t.integer "more_votes_than_ballots_flag"
    t.integer "more_votes_than_ballots"
    t.integer "votes 8-12"
    t.integer "votes 12-17",                                    :limit => 8
    t.integer "votes 17-20",                                    :limit => 8
    t.decimal "vpm 8-12",                                                     :precision => 14, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 15, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 15, :scale => 4
    t.integer "1 - Free Georgia count"
    t.decimal "1 - Free Georgia",                                             :precision => 17, :scale => 4
    t.integer "4 - National Democratic Party of Georgia count"
    t.decimal "4 - National Democratic Party of Georgia",                     :precision => 17, :scale => 4
    t.integer "5 - United National Movement count"
    t.decimal "5 - United National Movement",                                 :precision => 17, :scale => 4
    t.integer "9 - Movement for Fair Georgia count"
    t.decimal "9 - Movement for Fair Georgia",                                :precision => 17, :scale => 4
    t.integer "10 - Christian-Democratic Movement count"
    t.decimal "10 - Christian-Democratic Movement",                           :precision => 17, :scale => 4
    t.integer "17 - Public Movement count"
    t.decimal "17 - Public Movement",                                         :precision => 17, :scale => 4
    t.integer "19 - Freedom Party count"
    t.decimal "19 - Freedom Party",                                           :precision => 17, :scale => 4
    t.integer "23 - Georgian Group count"
    t.decimal "23 - Georgian Group",                                          :precision => 17, :scale => 4
    t.integer "24 - New Rights count"
    t.decimal "24 - New Rights",                                              :precision => 17, :scale => 4
    t.integer "26 - People's Party count"
    t.decimal "26 - People's Party",                                          :precision => 17, :scale => 4
    t.integer "30 - Merab Kostava Society count"
    t.decimal "30 - Merab Kostava Society",                                   :precision => 17, :scale => 4
    t.integer "35 - Future Georgia count"
    t.decimal "35 - Future Georgia",                                          :precision => 17, :scale => 4
    t.integer "36 - Labour Council of Georgia count"
    t.decimal "36 - Labour Council of Georgia",                               :precision => 17, :scale => 4
    t.integer "38 - Labour count"
    t.decimal "38 - Labour",                                                  :precision => 17, :scale => 4
    t.integer "40 - Sportsman's Union count"
    t.decimal "40 - Sportsman's Union",                                       :precision => 17, :scale => 4
    t.integer "41 - Georgian Dream count"
    t.decimal "41 - Georgian Dream",                                          :precision => 17, :scale => 4
  end

  create_table "2012_parliamentary_majoritarian - precinct count", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id",   :default => 0, :null => false
    t.integer "num_precincts"
  end

  add_index "2012_parliamentary_majoritarian - precinct count", ["district_id"], :name => "district"
  add_index "2012_parliamentary_majoritarian - precinct count", ["region"], :name => "region"

  create_table "2012_parliamentary_majoritarian - precinct count by country", :id => false, :force => true do |t|
    t.decimal "num_precincts", :precision => 32, :scale => 0
  end

  create_table "2012_parliamentary_majoritarian - precinct count by district", :id => false, :force => true do |t|
    t.integer "district_id",                                  :default => 0, :null => false
    t.decimal "num_precincts", :precision => 32, :scale => 0
  end

  create_table "2012_parliamentary_majoritarian - precinct count by region", :id => false, :force => true do |t|
    t.string  "region"
    t.decimal "num_precincts", :precision => 32, :scale => 0
  end

  create_table "2012_parliamentary_majoritarian - raw", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.string  "district_name"
    t.integer "precinct_id"
    t.integer "attached_precinct_id"
    t.integer "num_possible_voters"
    t.integer "num_special_voters"
    t.integer "num_at_12"
    t.integer "num_at_17"
    t.integer "num_votes"
    t.integer "num_ballots"
    t.integer "num_invalid_votes"
    t.integer "num_valid_votes"
    t.integer "logic_check_fail"
    t.integer "logic_check_difference"
    t.integer "more_ballots_than_votes_flag"
    t.integer "more_ballots_than_votes"
    t.integer "more_votes_than_ballots_flag"
    t.integer "more_votes_than_ballots"
    t.integer "1 - Free Georgia"
    t.integer "4 - National Democratic Party of Georgia"
    t.integer "5 - United National Movement"
    t.integer "9 - Movement for Fair Georgia"
    t.integer "10 - Christian-Democratic Movement"
    t.integer "17 - Public Movement"
    t.integer "19 - Freedom Party"
    t.integer "23 - Georgian Group"
    t.integer "24 - New Rights"
    t.integer "26 - People's Party"
    t.integer "30 - Merab Kostava Society"
    t.integer "35 - Future Georgia"
    t.integer "36 - Labour Council of Georgia"
    t.integer "38 - Labour"
    t.integer "40 - Sportsman's Union"
    t.integer "41 - Georgian Dream"
  end

  create_table "2012_parliamentary_majoritarian - region", :id => false, :force => true do |t|
    t.string  "region"
    t.decimal "possible voters",                                              :precision => 32, :scale => 0
    t.decimal "total ballots cast",                                           :precision => 32, :scale => 0
    t.decimal "total valid ballots cast",                                     :precision => 32, :scale => 0
    t.decimal "num invalid ballots from 0-1%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 1-3%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 3-5%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots >5%",                                      :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "percent voters voting",                                        :precision => 39, :scale => 4
    t.decimal "num precincts logic fail",                                     :precision => 32, :scale => 0
    t.decimal "percent precincts logic fail",                                 :precision => 39, :scale => 4
    t.decimal "avg precinct logic fail difference",                           :precision => 36, :scale => 4
    t.decimal "num precincts more ballots than votes",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more ballots than votes",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more ballots than votes",              :precision => 36, :scale => 4
    t.decimal "num precincts more votes than ballots",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more votes than ballots",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more votes than ballots",              :precision => 36, :scale => 4
    t.decimal "votes 8-12",                                                   :precision => 32, :scale => 0
    t.decimal "votes 12-17",                                                  :precision => 33, :scale => 0
    t.decimal "votes 17-20",                                                  :precision => 33, :scale => 0
    t.decimal "avg votes/precinct 8-12",                                      :precision => 36, :scale => 4
    t.decimal "avg votes/precinct 12-17",                                     :precision => 37, :scale => 4
    t.decimal "avg votes/precinct 17-20",                                     :precision => 37, :scale => 4
    t.decimal "vpm 8-12",                                                     :precision => 36, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 37, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 37, :scale => 4
    t.decimal "avg vpm/precinct 8-12",                                        :precision => 40, :scale => 8
    t.decimal "avg vpm/precinct 12-17",                                       :precision => 41, :scale => 8
    t.decimal "avg vpm/precinct 17-20",                                       :precision => 41, :scale => 8
    t.decimal "num precincts vpm 8-12 > 2",                                   :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 12-17 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 17-20 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm > 2",                                        :precision => 44, :scale => 0, :default => 0, :null => false
    t.decimal "num_precincts_possible",                                       :precision => 32, :scale => 0
    t.integer "num_precincts_reported_number",                   :limit => 8,                                :default => 0, :null => false
    t.decimal "num_precincts_reported_percent",                               :precision => 27, :scale => 4
    t.decimal "1 - Free Georgia count",                                       :precision => 32, :scale => 0
    t.decimal "1 - Free Georgia",                                             :precision => 39, :scale => 4
    t.decimal "4 - National Democratic Party of Georgia count",               :precision => 32, :scale => 0
    t.decimal "4 - National Democratic Party of Georgia",                     :precision => 39, :scale => 4
    t.decimal "5 - United National Movement count",                           :precision => 32, :scale => 0
    t.decimal "5 - United National Movement",                                 :precision => 39, :scale => 4
    t.decimal "9 - Movement for Fair Georgia count",                          :precision => 32, :scale => 0
    t.decimal "9 - Movement for Fair Georgia",                                :precision => 39, :scale => 4
    t.decimal "10 - Christian-Democratic Movement count",                     :precision => 32, :scale => 0
    t.decimal "10 - Christian-Democratic Movement",                           :precision => 39, :scale => 4
    t.decimal "17 - Public Movement count",                                   :precision => 32, :scale => 0
    t.decimal "17 - Public Movement",                                         :precision => 39, :scale => 4
    t.decimal "19 - Freedom Party count",                                     :precision => 32, :scale => 0
    t.decimal "19 - Freedom Party",                                           :precision => 39, :scale => 4
    t.decimal "23 - Georgian Group count",                                    :precision => 32, :scale => 0
    t.decimal "23 - Georgian Group",                                          :precision => 39, :scale => 4
    t.decimal "24 - New Rights count",                                        :precision => 32, :scale => 0
    t.decimal "24 - New Rights",                                              :precision => 39, :scale => 4
    t.decimal "26 - People's Party count",                                    :precision => 32, :scale => 0
    t.decimal "26 - People's Party",                                          :precision => 39, :scale => 4
    t.decimal "30 - Merab Kostava Society count",                             :precision => 32, :scale => 0
    t.decimal "30 - Merab Kostava Society",                                   :precision => 39, :scale => 4
    t.decimal "35 - Future Georgia count",                                    :precision => 32, :scale => 0
    t.decimal "35 - Future Georgia",                                          :precision => 39, :scale => 4
    t.decimal "36 - Labour Council of Georgia count",                         :precision => 32, :scale => 0
    t.decimal "36 - Labour Council of Georgia",                               :precision => 39, :scale => 4
    t.decimal "38 - Labour count",                                            :precision => 32, :scale => 0
    t.decimal "38 - Labour",                                                  :precision => 39, :scale => 4
    t.decimal "40 - Sportsman's Union count",                                 :precision => 32, :scale => 0
    t.decimal "40 - Sportsman's Union",                                       :precision => 39, :scale => 4
    t.decimal "41 - Georgian Dream count",                                    :precision => 32, :scale => 0
    t.decimal "41 - Georgian Dream",                                          :precision => 39, :scale => 4
  end

  create_table "2012_parliamentary_majoritarian - tbilisi district", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.string  "district_Name"
    t.decimal "possible voters",                                              :precision => 32, :scale => 0
    t.decimal "total ballots cast",                                           :precision => 32, :scale => 0
    t.decimal "total valid ballots cast",                                     :precision => 32, :scale => 0
    t.decimal "num invalid ballots from 0-1%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 1-3%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 3-5%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots >5%",                                      :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "percent voters voting",                                        :precision => 39, :scale => 4
    t.decimal "num precincts logic fail",                                     :precision => 32, :scale => 0
    t.decimal "percent precincts logic fail",                                 :precision => 39, :scale => 4
    t.decimal "avg precinct logic fail difference",                           :precision => 36, :scale => 4
    t.decimal "num precincts more ballots than votes",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more ballots than votes",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more ballots than votes",              :precision => 36, :scale => 4
    t.decimal "num precincts more votes than ballots",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more votes than ballots",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more votes than ballots",              :precision => 36, :scale => 4
    t.decimal "votes 8-12",                                                   :precision => 32, :scale => 0
    t.decimal "votes 12-17",                                                  :precision => 33, :scale => 0
    t.decimal "votes 17-20",                                                  :precision => 33, :scale => 0
    t.decimal "avg votes/precinct 8-12",                                      :precision => 36, :scale => 4
    t.decimal "avg votes/precinct 12-17",                                     :precision => 37, :scale => 4
    t.decimal "avg votes/precinct 17-20",                                     :precision => 37, :scale => 4
    t.decimal "vpm 8-12",                                                     :precision => 36, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 37, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 37, :scale => 4
    t.decimal "avg vpm/precinct 8-12",                                        :precision => 40, :scale => 8
    t.decimal "avg vpm/precinct 12-17",                                       :precision => 41, :scale => 8
    t.decimal "avg vpm/precinct 17-20",                                       :precision => 41, :scale => 8
    t.decimal "num precincts vpm 8-12 > 2",                                   :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 12-17 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 17-20 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm > 2",                                        :precision => 44, :scale => 0, :default => 0, :null => false
    t.decimal "num_precincts_possible",                                       :precision => 32, :scale => 0
    t.integer "num_precincts_reported_number",                   :limit => 8,                                :default => 0, :null => false
    t.decimal "num_precincts_reported_percent",                               :precision => 27, :scale => 4
    t.decimal "1 - Free Georgia count",                                       :precision => 32, :scale => 0
    t.decimal "1 - Free Georgia",                                             :precision => 39, :scale => 4
    t.decimal "4 - National Democratic Party of Georgia count",               :precision => 32, :scale => 0
    t.decimal "4 - National Democratic Party of Georgia",                     :precision => 39, :scale => 4
    t.decimal "5 - United National Movement count",                           :precision => 32, :scale => 0
    t.decimal "5 - United National Movement",                                 :precision => 39, :scale => 4
    t.decimal "9 - Movement for Fair Georgia count",                          :precision => 32, :scale => 0
    t.decimal "9 - Movement for Fair Georgia",                                :precision => 39, :scale => 4
    t.decimal "10 - Christian-Democratic Movement count",                     :precision => 32, :scale => 0
    t.decimal "10 - Christian-Democratic Movement",                           :precision => 39, :scale => 4
    t.decimal "17 - Public Movement count",                                   :precision => 32, :scale => 0
    t.decimal "17 - Public Movement",                                         :precision => 39, :scale => 4
    t.decimal "19 - Freedom Party count",                                     :precision => 32, :scale => 0
    t.decimal "19 - Freedom Party",                                           :precision => 39, :scale => 4
    t.decimal "23 - Georgian Group count",                                    :precision => 32, :scale => 0
    t.decimal "23 - Georgian Group",                                          :precision => 39, :scale => 4
    t.decimal "24 - New Rights count",                                        :precision => 32, :scale => 0
    t.decimal "24 - New Rights",                                              :precision => 39, :scale => 4
    t.decimal "26 - People's Party count",                                    :precision => 32, :scale => 0
    t.decimal "26 - People's Party",                                          :precision => 39, :scale => 4
    t.decimal "30 - Merab Kostava Society count",                             :precision => 32, :scale => 0
    t.decimal "30 - Merab Kostava Society",                                   :precision => 39, :scale => 4
    t.decimal "35 - Future Georgia count",                                    :precision => 32, :scale => 0
    t.decimal "35 - Future Georgia",                                          :precision => 39, :scale => 4
    t.decimal "36 - Labour Council of Georgia count",                         :precision => 32, :scale => 0
    t.decimal "36 - Labour Council of Georgia",                               :precision => 39, :scale => 4
    t.decimal "38 - Labour count",                                            :precision => 32, :scale => 0
    t.decimal "38 - Labour",                                                  :precision => 39, :scale => 4
    t.decimal "40 - Sportsman's Union count",                                 :precision => 32, :scale => 0
    t.decimal "40 - Sportsman's Union",                                       :precision => 39, :scale => 4
    t.decimal "41 - Georgian Dream count",                                    :precision => 32, :scale => 0
    t.decimal "41 - Georgian Dream",                                          :precision => 39, :scale => 4
  end

  create_table "2012_parliamentary_majoritarian - tbilisi precinct", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.string  "district_Name"
    t.integer "precinct_id"
    t.string  "precinct_name",                                  :limit => 23
    t.integer "possible voters"
    t.integer "total ballots cast"
    t.integer "total valid ballots cast"
    t.decimal "percent invalid ballots",                                      :precision => 17, :scale => 4
    t.decimal "percent voters voting",                                        :precision => 17, :scale => 4
    t.integer "logic_check_fail"
    t.integer "logic_check_difference"
    t.integer "more_ballots_than_votes_flag"
    t.integer "more_ballots_than_votes"
    t.integer "more_votes_than_ballots_flag"
    t.integer "more_votes_than_ballots"
    t.integer "votes 8-12"
    t.integer "votes 12-17",                                    :limit => 8
    t.integer "votes 17-20",                                    :limit => 8
    t.decimal "vpm 8-12",                                                     :precision => 14, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 15, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 15, :scale => 4
    t.integer "1 - Free Georgia count"
    t.decimal "1 - Free Georgia",                                             :precision => 17, :scale => 4
    t.integer "4 - National Democratic Party of Georgia count"
    t.decimal "4 - National Democratic Party of Georgia",                     :precision => 17, :scale => 4
    t.integer "5 - United National Movement count"
    t.decimal "5 - United National Movement",                                 :precision => 17, :scale => 4
    t.integer "9 - Movement for Fair Georgia count"
    t.decimal "9 - Movement for Fair Georgia",                                :precision => 17, :scale => 4
    t.integer "10 - Christian-Democratic Movement count"
    t.decimal "10 - Christian-Democratic Movement",                           :precision => 17, :scale => 4
    t.integer "17 - Public Movement count"
    t.decimal "17 - Public Movement",                                         :precision => 17, :scale => 4
    t.integer "19 - Freedom Party count"
    t.decimal "19 - Freedom Party",                                           :precision => 17, :scale => 4
    t.integer "23 - Georgian Group count"
    t.decimal "23 - Georgian Group",                                          :precision => 17, :scale => 4
    t.integer "24 - New Rights count"
    t.decimal "24 - New Rights",                                              :precision => 17, :scale => 4
    t.integer "26 - People's Party count"
    t.decimal "26 - People's Party",                                          :precision => 17, :scale => 4
    t.integer "30 - Merab Kostava Society count"
    t.decimal "30 - Merab Kostava Society",                                   :precision => 17, :scale => 4
    t.integer "35 - Future Georgia count"
    t.decimal "35 - Future Georgia",                                          :precision => 17, :scale => 4
    t.integer "36 - Labour Council of Georgia count"
    t.decimal "36 - Labour Council of Georgia",                               :precision => 17, :scale => 4
    t.integer "38 - Labour count"
    t.decimal "38 - Labour",                                                  :precision => 17, :scale => 4
    t.integer "40 - Sportsman's Union count"
    t.decimal "40 - Sportsman's Union",                                       :precision => 17, :scale => 4
    t.integer "41 - Georgian Dream count"
    t.decimal "41 - Georgian Dream",                                          :precision => 17, :scale => 4
  end

  create_table "2012_parliamentary_majoritarian - vpm 12-17>2", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "vpm > 2",     :limit => 8, :default => 0, :null => false
  end

  create_table "2012_parliamentary_majoritarian - vpm 17-20>2", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "vpm > 2",     :limit => 8, :default => 0, :null => false
  end

  create_table "2012_parliamentary_majoritarian - vpm 8-12>2", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "vpm > 2",     :limit => 8, :default => 0, :null => false
  end

  create_table "2012_parliamentary_party_list - country", :id => false, :force => true do |t|
    t.decimal "possible voters",                                              :precision => 32, :scale => 0
    t.decimal "total ballots cast",                                           :precision => 32, :scale => 0
    t.decimal "total valid ballots cast",                                     :precision => 32, :scale => 0
    t.decimal "num invalid ballots from 0-1%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 1-3%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 3-5%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots >5%",                                      :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "percent voters voting",                                        :precision => 39, :scale => 4
    t.decimal "num precincts logic fail",                                     :precision => 32, :scale => 0
    t.decimal "percent precincts logic fail",                                 :precision => 39, :scale => 4
    t.decimal "avg precinct logic fail difference",                           :precision => 36, :scale => 4
    t.decimal "num precincts more ballots than votes",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more ballots than votes",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more ballots than votes",              :precision => 36, :scale => 4
    t.decimal "num precincts more votes than ballots",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more votes than ballots",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more votes than ballots",              :precision => 36, :scale => 4
    t.decimal "votes 8-12",                                                   :precision => 32, :scale => 0
    t.decimal "votes 12-17",                                                  :precision => 33, :scale => 0
    t.decimal "votes 17-20",                                                  :precision => 33, :scale => 0
    t.decimal "avg votes/precinct 8-12",                                      :precision => 36, :scale => 4
    t.decimal "avg votes/precinct 12-17",                                     :precision => 37, :scale => 4
    t.decimal "avg votes/precinct 17-20",                                     :precision => 37, :scale => 4
    t.decimal "vpm 8-12",                                                     :precision => 36, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 37, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 37, :scale => 4
    t.decimal "avg vpm/precinct 8-12",                                        :precision => 40, :scale => 8
    t.decimal "avg vpm/precinct 12-17",                                       :precision => 41, :scale => 8
    t.decimal "avg vpm/precinct 17-20",                                       :precision => 41, :scale => 8
    t.decimal "num precincts vpm 8-12 > 2",                                   :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 12-17 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 17-20 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm > 2",                                        :precision => 44, :scale => 0, :default => 0, :null => false
    t.decimal "num_precincts_possible",                                       :precision => 32, :scale => 0
    t.integer "num_precincts_reported_number",                   :limit => 8,                                :default => 0, :null => false
    t.decimal "num_precincts_reported_percent",                               :precision => 27, :scale => 4
    t.decimal "1 - Free Georgia count",                                       :precision => 32, :scale => 0
    t.decimal "1 - Free Georgia",                                             :precision => 39, :scale => 4
    t.decimal "4 - National Democratic Party of Georgia count",               :precision => 32, :scale => 0
    t.decimal "4 - National Democratic Party of Georgia",                     :precision => 39, :scale => 4
    t.decimal "5 - United National Movement count",                           :precision => 32, :scale => 0
    t.decimal "5 - United National Movement",                                 :precision => 39, :scale => 4
    t.decimal "9 - Movement for Fair Georgia count",                          :precision => 32, :scale => 0
    t.decimal "9 - Movement for Fair Georgia",                                :precision => 39, :scale => 4
    t.decimal "10 - Christian-Democratic Movement count",                     :precision => 32, :scale => 0
    t.decimal "10 - Christian-Democratic Movement",                           :precision => 39, :scale => 4
    t.decimal "17 - Public Movement count",                                   :precision => 32, :scale => 0
    t.decimal "17 - Public Movement",                                         :precision => 39, :scale => 4
    t.decimal "19 - Freedom Party count",                                     :precision => 32, :scale => 0
    t.decimal "19 - Freedom Party",                                           :precision => 39, :scale => 4
    t.decimal "23 - Georgian Group count",                                    :precision => 32, :scale => 0
    t.decimal "23 - Georgian Group",                                          :precision => 39, :scale => 4
    t.decimal "24 - New Rights count",                                        :precision => 32, :scale => 0
    t.decimal "24 - New Rights",                                              :precision => 39, :scale => 4
    t.decimal "26 - People's Party count",                                    :precision => 32, :scale => 0
    t.decimal "26 - People's Party",                                          :precision => 39, :scale => 4
    t.decimal "30 - Merab Kostava Society count",                             :precision => 32, :scale => 0
    t.decimal "30 - Merab Kostava Society",                                   :precision => 39, :scale => 4
    t.decimal "35 - Future Georgia count",                                    :precision => 32, :scale => 0
    t.decimal "35 - Future Georgia",                                          :precision => 39, :scale => 4
    t.decimal "36 - Labour Council of Georgia count",                         :precision => 32, :scale => 0
    t.decimal "36 - Labour Council of Georgia",                               :precision => 39, :scale => 4
    t.decimal "38 - Labour count",                                            :precision => 32, :scale => 0
    t.decimal "38 - Labour",                                                  :precision => 39, :scale => 4
    t.decimal "40 - Sportsman's Union count",                                 :precision => 32, :scale => 0
    t.decimal "40 - Sportsman's Union",                                       :precision => 39, :scale => 4
    t.decimal "41 - Georgian Dream count",                                    :precision => 32, :scale => 0
    t.decimal "41 - Georgian Dream",                                          :precision => 39, :scale => 4
  end

  create_table "2012_parliamentary_party_list - csv", :id => false, :force => true do |t|
    t.string  "shape",                                                       :limit => 16,                                :default => "", :null => false
    t.string  "common_id"
    t.string  "common_name"
    t.decimal "Total Voter Turnout (#)",                                                   :precision => 32, :scale => 0
    t.decimal "Total Voter Turnout (%)",                                                   :precision => 39, :scale => 4
    t.decimal "Number of Precincts with Invalid Ballots from 0-1%",                        :precision => 42, :scale => 0
    t.decimal "Number of Precincts with Invalid Ballots from 1-3%",                        :precision => 42, :scale => 0
    t.decimal "Number of Precincts with Invalid Ballots from 3-5%",                        :precision => 42, :scale => 0
    t.decimal "Number of Precincts with Invalid Ballots > 5%",                             :precision => 42, :scale => 0
    t.decimal "Invalid Ballots (%)",                                                       :precision => 17, :scale => 4
    t.decimal "Precincts with More Ballots Than Votes (#)",                                :precision => 32, :scale => 0
    t.decimal "Precincts with More Ballots Than Votes (%)",                                :precision => 39, :scale => 4
    t.decimal "More Ballots Than Votes (Average)",                                         :precision => 36, :scale => 4
    t.integer "More Ballots Than Votes (#)"
    t.decimal "Precincts with More Votes than Ballots (#)",                                :precision => 32, :scale => 0
    t.decimal "Precincts with More Votes than Ballots (%)",                                :precision => 39, :scale => 4
    t.decimal "More Votes than Ballots (Average)",                                         :precision => 36, :scale => 4
    t.integer "More Votes than Ballots (#)"
    t.decimal "Average votes per minute (08:00-12:00)",                                    :precision => 14, :scale => 4
    t.decimal "Average votes per minute (12:00-17:00)",                                    :precision => 15, :scale => 4
    t.decimal "Average votes per minute (17:00-20:00)",                                    :precision => 15, :scale => 4
    t.decimal "Number of Precincts with votes per minute > 2 (08:00-12:00)",               :precision => 42, :scale => 0
    t.decimal "Number of Precincts with votes per minute > 2 (12:00-17:00)",               :precision => 42, :scale => 0
    t.decimal "Number of Precincts with votes per minute > 2 (17:00-20:00)",               :precision => 42, :scale => 0
    t.decimal "Number of Precincts with votes per minute > 2",                             :precision => 44, :scale => 0
    t.integer "Precincts Reported (#)",                                      :limit => 8
    t.decimal "Precincts Reported (%)",                                                    :precision => 27, :scale => 4
    t.decimal "Free Georgia",                                                              :precision => 39, :scale => 4
    t.decimal "National Democratic Party of Georgia",                                      :precision => 39, :scale => 4
    t.decimal "United National Movement",                                                  :precision => 39, :scale => 4
    t.decimal "Movement for Fair Georgia",                                                 :precision => 39, :scale => 4
    t.decimal "Christian-Democratic Movement",                                             :precision => 39, :scale => 4
    t.decimal "Public Movement",                                                           :precision => 39, :scale => 4
    t.decimal "Freedom Party",                                                             :precision => 39, :scale => 4
    t.decimal "Georgian Group",                                                            :precision => 39, :scale => 4
    t.decimal "New Rights",                                                                :precision => 39, :scale => 4
    t.decimal "People's Party",                                                            :precision => 39, :scale => 4
    t.decimal "Merab Kostava Society",                                                     :precision => 39, :scale => 4
    t.decimal "Future Georgia",                                                            :precision => 39, :scale => 4
    t.decimal "Labour Council of Georgia",                                                 :precision => 39, :scale => 4
    t.decimal "Labour",                                                                    :precision => 39, :scale => 4
    t.decimal "Sportsman's Union",                                                         :precision => 39, :scale => 4
    t.decimal "Georgian Dream",                                                            :precision => 39, :scale => 4
  end

  create_table "2012_parliamentary_party_list - district", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id",                                     :limit => 8
    t.string  "district_Name"
    t.decimal "possible voters",                                              :precision => 32, :scale => 0
    t.decimal "total ballots cast",                                           :precision => 32, :scale => 0
    t.decimal "total valid ballots cast",                                     :precision => 32, :scale => 0
    t.decimal "num invalid ballots from 0-1%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 1-3%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 3-5%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots >5%",                                      :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "percent voters voting",                                        :precision => 39, :scale => 4
    t.decimal "num precincts logic fail",                                     :precision => 32, :scale => 0
    t.decimal "percent precincts logic fail",                                 :precision => 39, :scale => 4
    t.decimal "avg precinct logic fail difference",                           :precision => 36, :scale => 4
    t.decimal "num precincts more ballots than votes",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more ballots than votes",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more ballots than votes",              :precision => 36, :scale => 4
    t.decimal "num precincts more votes than ballots",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more votes than ballots",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more votes than ballots",              :precision => 36, :scale => 4
    t.decimal "votes 8-12",                                                   :precision => 32, :scale => 0
    t.decimal "votes 12-17",                                                  :precision => 33, :scale => 0
    t.decimal "votes 17-20",                                                  :precision => 33, :scale => 0
    t.decimal "avg votes/precinct 8-12",                                      :precision => 36, :scale => 4
    t.decimal "avg votes/precinct 12-17",                                     :precision => 37, :scale => 4
    t.decimal "avg votes/precinct 17-20",                                     :precision => 37, :scale => 4
    t.decimal "vpm 8-12",                                                     :precision => 36, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 37, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 37, :scale => 4
    t.decimal "avg vpm/precinct 8-12",                                        :precision => 40, :scale => 8
    t.decimal "avg vpm/precinct 12-17",                                       :precision => 41, :scale => 8
    t.decimal "avg vpm/precinct 17-20",                                       :precision => 41, :scale => 8
    t.decimal "num precincts vpm 8-12 > 2",                                   :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 12-17 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 17-20 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm > 2",                                        :precision => 44, :scale => 0, :default => 0, :null => false
    t.decimal "num_precincts_possible",                                       :precision => 32, :scale => 0
    t.integer "num_precincts_reported_number",                   :limit => 8,                                :default => 0, :null => false
    t.decimal "num_precincts_reported_percent",                               :precision => 27, :scale => 4
    t.decimal "1 - Free Georgia count",                                       :precision => 32, :scale => 0
    t.decimal "1 - Free Georgia",                                             :precision => 39, :scale => 4
    t.decimal "4 - National Democratic Party of Georgia count",               :precision => 32, :scale => 0
    t.decimal "4 - National Democratic Party of Georgia",                     :precision => 39, :scale => 4
    t.decimal "5 - United National Movement count",                           :precision => 32, :scale => 0
    t.decimal "5 - United National Movement",                                 :precision => 39, :scale => 4
    t.decimal "9 - Movement for Fair Georgia count",                          :precision => 32, :scale => 0
    t.decimal "9 - Movement for Fair Georgia",                                :precision => 39, :scale => 4
    t.decimal "10 - Christian-Democratic Movement count",                     :precision => 32, :scale => 0
    t.decimal "10 - Christian-Democratic Movement",                           :precision => 39, :scale => 4
    t.decimal "17 - Public Movement count",                                   :precision => 32, :scale => 0
    t.decimal "17 - Public Movement",                                         :precision => 39, :scale => 4
    t.decimal "19 - Freedom Party count",                                     :precision => 32, :scale => 0
    t.decimal "19 - Freedom Party",                                           :precision => 39, :scale => 4
    t.decimal "23 - Georgian Group count",                                    :precision => 32, :scale => 0
    t.decimal "23 - Georgian Group",                                          :precision => 39, :scale => 4
    t.decimal "24 - New Rights count",                                        :precision => 32, :scale => 0
    t.decimal "24 - New Rights",                                              :precision => 39, :scale => 4
    t.decimal "26 - People's Party count",                                    :precision => 32, :scale => 0
    t.decimal "26 - People's Party",                                          :precision => 39, :scale => 4
    t.decimal "30 - Merab Kostava Society count",                             :precision => 32, :scale => 0
    t.decimal "30 - Merab Kostava Society",                                   :precision => 39, :scale => 4
    t.decimal "35 - Future Georgia count",                                    :precision => 32, :scale => 0
    t.decimal "35 - Future Georgia",                                          :precision => 39, :scale => 4
    t.decimal "36 - Labour Council of Georgia count",                         :precision => 32, :scale => 0
    t.decimal "36 - Labour Council of Georgia",                               :precision => 39, :scale => 4
    t.decimal "38 - Labour count",                                            :precision => 32, :scale => 0
    t.decimal "38 - Labour",                                                  :precision => 39, :scale => 4
    t.decimal "40 - Sportsman's Union count",                                 :precision => 32, :scale => 0
    t.decimal "40 - Sportsman's Union",                                       :precision => 39, :scale => 4
    t.decimal "41 - Georgian Dream count",                                    :precision => 32, :scale => 0
    t.decimal "41 - Georgian Dream",                                          :precision => 39, :scale => 4
  end

  create_table "2012_parliamentary_party_list - invalid ballots 0-1", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "num_invalid_ballots", :limit => 8, :default => 0, :null => false
  end

  create_table "2012_parliamentary_party_list - invalid ballots 1-3", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "num_invalid_ballots", :limit => 8, :default => 0, :null => false
  end

  create_table "2012_parliamentary_party_list - invalid ballots 3-5", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "num_invalid_ballots", :limit => 8, :default => 0, :null => false
  end

  create_table "2012_parliamentary_party_list - invalid ballots >5", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "num_invalid_ballots", :limit => 8, :default => 0, :null => false
  end

  create_table "2012_parliamentary_party_list - precinct", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.string  "district_Name"
    t.integer "precinct_id"
    t.string  "precinct_name",                                  :limit => 23
    t.integer "possible voters"
    t.integer "total ballots cast"
    t.integer "total valid ballots cast"
    t.decimal "percent invalid ballots",                                      :precision => 17, :scale => 4
    t.decimal "percent voters voting",                                        :precision => 17, :scale => 4
    t.integer "logic_check_fail"
    t.integer "logic_check_difference"
    t.integer "more_ballots_than_votes_flag"
    t.integer "more_ballots_than_votes"
    t.integer "more_votes_than_ballots_flag"
    t.integer "more_votes_than_ballots"
    t.integer "votes 8-12"
    t.integer "votes 12-17",                                    :limit => 8
    t.integer "votes 17-20",                                    :limit => 8
    t.decimal "vpm 8-12",                                                     :precision => 14, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 15, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 15, :scale => 4
    t.integer "1 - Free Georgia count"
    t.decimal "1 - Free Georgia",                                             :precision => 17, :scale => 4
    t.integer "4 - National Democratic Party of Georgia count"
    t.decimal "4 - National Democratic Party of Georgia",                     :precision => 17, :scale => 4
    t.integer "5 - United National Movement count"
    t.decimal "5 - United National Movement",                                 :precision => 17, :scale => 4
    t.integer "9 - Movement for Fair Georgia count"
    t.decimal "9 - Movement for Fair Georgia",                                :precision => 17, :scale => 4
    t.integer "10 - Christian-Democratic Movement count"
    t.decimal "10 - Christian-Democratic Movement",                           :precision => 17, :scale => 4
    t.integer "17 - Public Movement count"
    t.decimal "17 - Public Movement",                                         :precision => 17, :scale => 4
    t.integer "19 - Freedom Party count"
    t.decimal "19 - Freedom Party",                                           :precision => 17, :scale => 4
    t.integer "23 - Georgian Group count"
    t.decimal "23 - Georgian Group",                                          :precision => 17, :scale => 4
    t.integer "24 - New Rights count"
    t.decimal "24 - New Rights",                                              :precision => 17, :scale => 4
    t.integer "26 - People's Party count"
    t.decimal "26 - People's Party",                                          :precision => 17, :scale => 4
    t.integer "30 - Merab Kostava Society count"
    t.decimal "30 - Merab Kostava Society",                                   :precision => 17, :scale => 4
    t.integer "35 - Future Georgia count"
    t.decimal "35 - Future Georgia",                                          :precision => 17, :scale => 4
    t.integer "36 - Labour Council of Georgia count"
    t.decimal "36 - Labour Council of Georgia",                               :precision => 17, :scale => 4
    t.integer "38 - Labour count"
    t.decimal "38 - Labour",                                                  :precision => 17, :scale => 4
    t.integer "40 - Sportsman's Union count"
    t.decimal "40 - Sportsman's Union",                                       :precision => 17, :scale => 4
    t.integer "41 - Georgian Dream count"
    t.decimal "41 - Georgian Dream",                                          :precision => 17, :scale => 4
  end

  create_table "2012_parliamentary_party_list - precinct count", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id",   :default => 0, :null => false
    t.integer "num_precincts"
  end

  add_index "2012_parliamentary_party_list - precinct count", ["district_id"], :name => "district"
  add_index "2012_parliamentary_party_list - precinct count", ["region"], :name => "region"

  create_table "2012_parliamentary_party_list - precinct count by country", :id => false, :force => true do |t|
    t.decimal "num_precincts", :precision => 32, :scale => 0
  end

  create_table "2012_parliamentary_party_list - precinct count by district", :id => false, :force => true do |t|
    t.integer "district_id",                                  :default => 0, :null => false
    t.decimal "num_precincts", :precision => 32, :scale => 0
  end

  create_table "2012_parliamentary_party_list - precinct count by region", :id => false, :force => true do |t|
    t.string  "region"
    t.decimal "num_precincts", :precision => 32, :scale => 0
  end

  create_table "2012_parliamentary_party_list - raw", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.string  "district_name"
    t.integer "precinct_id"
    t.integer "attached_precinct_id"
    t.integer "num_possible_voters"
    t.integer "num_special_voters"
    t.integer "num_at_12"
    t.integer "num_at_17"
    t.integer "num_votes"
    t.integer "num_ballots"
    t.integer "num_invalid_votes"
    t.integer "num_valid_votes"
    t.integer "logic_check_fail"
    t.integer "logic_check_difference"
    t.integer "more_ballots_than_votes_flag"
    t.integer "more_ballots_than_votes"
    t.integer "more_votes_than_ballots_flag"
    t.integer "more_votes_than_ballots"
    t.integer "1 - Free Georgia"
    t.integer "4 - National Democratic Party of Georgia"
    t.integer "5 - United National Movement"
    t.integer "9 - Movement for Fair Georgia"
    t.integer "10 - Christian-Democratic Movement"
    t.integer "17 - Public Movement"
    t.integer "19 - Freedom Party"
    t.integer "23 - Georgian Group"
    t.integer "24 - New Rights"
    t.integer "26 - People's Party"
    t.integer "30 - Merab Kostava Society"
    t.integer "35 - Future Georgia"
    t.integer "36 - Labour Council of Georgia"
    t.integer "38 - Labour"
    t.integer "40 - Sportsman's Union"
    t.integer "41 - Georgian Dream"
  end

  create_table "2012_parliamentary_party_list - region", :id => false, :force => true do |t|
    t.string  "region"
    t.decimal "possible voters",                                              :precision => 32, :scale => 0
    t.decimal "total ballots cast",                                           :precision => 32, :scale => 0
    t.decimal "total valid ballots cast",                                     :precision => 32, :scale => 0
    t.decimal "num invalid ballots from 0-1%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 1-3%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 3-5%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots >5%",                                      :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "percent voters voting",                                        :precision => 39, :scale => 4
    t.decimal "num precincts logic fail",                                     :precision => 32, :scale => 0
    t.decimal "percent precincts logic fail",                                 :precision => 39, :scale => 4
    t.decimal "avg precinct logic fail difference",                           :precision => 36, :scale => 4
    t.decimal "num precincts more ballots than votes",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more ballots than votes",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more ballots than votes",              :precision => 36, :scale => 4
    t.decimal "num precincts more votes than ballots",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more votes than ballots",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more votes than ballots",              :precision => 36, :scale => 4
    t.decimal "votes 8-12",                                                   :precision => 32, :scale => 0
    t.decimal "votes 12-17",                                                  :precision => 33, :scale => 0
    t.decimal "votes 17-20",                                                  :precision => 33, :scale => 0
    t.decimal "avg votes/precinct 8-12",                                      :precision => 36, :scale => 4
    t.decimal "avg votes/precinct 12-17",                                     :precision => 37, :scale => 4
    t.decimal "avg votes/precinct 17-20",                                     :precision => 37, :scale => 4
    t.decimal "vpm 8-12",                                                     :precision => 36, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 37, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 37, :scale => 4
    t.decimal "avg vpm/precinct 8-12",                                        :precision => 40, :scale => 8
    t.decimal "avg vpm/precinct 12-17",                                       :precision => 41, :scale => 8
    t.decimal "avg vpm/precinct 17-20",                                       :precision => 41, :scale => 8
    t.decimal "num precincts vpm 8-12 > 2",                                   :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 12-17 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 17-20 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm > 2",                                        :precision => 44, :scale => 0, :default => 0, :null => false
    t.decimal "num_precincts_possible",                                       :precision => 32, :scale => 0
    t.integer "num_precincts_reported_number",                   :limit => 8,                                :default => 0, :null => false
    t.decimal "num_precincts_reported_percent",                               :precision => 27, :scale => 4
    t.decimal "1 - Free Georgia count",                                       :precision => 32, :scale => 0
    t.decimal "1 - Free Georgia",                                             :precision => 39, :scale => 4
    t.decimal "4 - National Democratic Party of Georgia count",               :precision => 32, :scale => 0
    t.decimal "4 - National Democratic Party of Georgia",                     :precision => 39, :scale => 4
    t.decimal "5 - United National Movement count",                           :precision => 32, :scale => 0
    t.decimal "5 - United National Movement",                                 :precision => 39, :scale => 4
    t.decimal "9 - Movement for Fair Georgia count",                          :precision => 32, :scale => 0
    t.decimal "9 - Movement for Fair Georgia",                                :precision => 39, :scale => 4
    t.decimal "10 - Christian-Democratic Movement count",                     :precision => 32, :scale => 0
    t.decimal "10 - Christian-Democratic Movement",                           :precision => 39, :scale => 4
    t.decimal "17 - Public Movement count",                                   :precision => 32, :scale => 0
    t.decimal "17 - Public Movement",                                         :precision => 39, :scale => 4
    t.decimal "19 - Freedom Party count",                                     :precision => 32, :scale => 0
    t.decimal "19 - Freedom Party",                                           :precision => 39, :scale => 4
    t.decimal "23 - Georgian Group count",                                    :precision => 32, :scale => 0
    t.decimal "23 - Georgian Group",                                          :precision => 39, :scale => 4
    t.decimal "24 - New Rights count",                                        :precision => 32, :scale => 0
    t.decimal "24 - New Rights",                                              :precision => 39, :scale => 4
    t.decimal "26 - People's Party count",                                    :precision => 32, :scale => 0
    t.decimal "26 - People's Party",                                          :precision => 39, :scale => 4
    t.decimal "30 - Merab Kostava Society count",                             :precision => 32, :scale => 0
    t.decimal "30 - Merab Kostava Society",                                   :precision => 39, :scale => 4
    t.decimal "35 - Future Georgia count",                                    :precision => 32, :scale => 0
    t.decimal "35 - Future Georgia",                                          :precision => 39, :scale => 4
    t.decimal "36 - Labour Council of Georgia count",                         :precision => 32, :scale => 0
    t.decimal "36 - Labour Council of Georgia",                               :precision => 39, :scale => 4
    t.decimal "38 - Labour count",                                            :precision => 32, :scale => 0
    t.decimal "38 - Labour",                                                  :precision => 39, :scale => 4
    t.decimal "40 - Sportsman's Union count",                                 :precision => 32, :scale => 0
    t.decimal "40 - Sportsman's Union",                                       :precision => 39, :scale => 4
    t.decimal "41 - Georgian Dream count",                                    :precision => 32, :scale => 0
    t.decimal "41 - Georgian Dream",                                          :precision => 39, :scale => 4
  end

  create_table "2012_parliamentary_party_list - tbilisi district", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.string  "district_Name"
    t.decimal "possible voters",                                              :precision => 32, :scale => 0
    t.decimal "total ballots cast",                                           :precision => 32, :scale => 0
    t.decimal "total valid ballots cast",                                     :precision => 32, :scale => 0
    t.decimal "num invalid ballots from 0-1%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 1-3%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 3-5%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots >5%",                                      :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "percent voters voting",                                        :precision => 39, :scale => 4
    t.decimal "num precincts logic fail",                                     :precision => 32, :scale => 0
    t.decimal "percent precincts logic fail",                                 :precision => 39, :scale => 4
    t.decimal "avg precinct logic fail difference",                           :precision => 36, :scale => 4
    t.decimal "num precincts more ballots than votes",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more ballots than votes",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more ballots than votes",              :precision => 36, :scale => 4
    t.decimal "num precincts more votes than ballots",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more votes than ballots",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more votes than ballots",              :precision => 36, :scale => 4
    t.decimal "votes 8-12",                                                   :precision => 32, :scale => 0
    t.decimal "votes 12-17",                                                  :precision => 33, :scale => 0
    t.decimal "votes 17-20",                                                  :precision => 33, :scale => 0
    t.decimal "avg votes/precinct 8-12",                                      :precision => 36, :scale => 4
    t.decimal "avg votes/precinct 12-17",                                     :precision => 37, :scale => 4
    t.decimal "avg votes/precinct 17-20",                                     :precision => 37, :scale => 4
    t.decimal "vpm 8-12",                                                     :precision => 36, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 37, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 37, :scale => 4
    t.decimal "avg vpm/precinct 8-12",                                        :precision => 40, :scale => 8
    t.decimal "avg vpm/precinct 12-17",                                       :precision => 41, :scale => 8
    t.decimal "avg vpm/precinct 17-20",                                       :precision => 41, :scale => 8
    t.decimal "num precincts vpm 8-12 > 2",                                   :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 12-17 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 17-20 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm > 2",                                        :precision => 44, :scale => 0, :default => 0, :null => false
    t.decimal "num_precincts_possible",                                       :precision => 32, :scale => 0
    t.integer "num_precincts_reported_number",                   :limit => 8,                                :default => 0, :null => false
    t.decimal "num_precincts_reported_percent",                               :precision => 27, :scale => 4
    t.decimal "1 - Free Georgia count",                                       :precision => 32, :scale => 0
    t.decimal "1 - Free Georgia",                                             :precision => 39, :scale => 4
    t.decimal "4 - National Democratic Party of Georgia count",               :precision => 32, :scale => 0
    t.decimal "4 - National Democratic Party of Georgia",                     :precision => 39, :scale => 4
    t.decimal "5 - United National Movement count",                           :precision => 32, :scale => 0
    t.decimal "5 - United National Movement",                                 :precision => 39, :scale => 4
    t.decimal "9 - Movement for Fair Georgia count",                          :precision => 32, :scale => 0
    t.decimal "9 - Movement for Fair Georgia",                                :precision => 39, :scale => 4
    t.decimal "10 - Christian-Democratic Movement count",                     :precision => 32, :scale => 0
    t.decimal "10 - Christian-Democratic Movement",                           :precision => 39, :scale => 4
    t.decimal "17 - Public Movement count",                                   :precision => 32, :scale => 0
    t.decimal "17 - Public Movement",                                         :precision => 39, :scale => 4
    t.decimal "19 - Freedom Party count",                                     :precision => 32, :scale => 0
    t.decimal "19 - Freedom Party",                                           :precision => 39, :scale => 4
    t.decimal "23 - Georgian Group count",                                    :precision => 32, :scale => 0
    t.decimal "23 - Georgian Group",                                          :precision => 39, :scale => 4
    t.decimal "24 - New Rights count",                                        :precision => 32, :scale => 0
    t.decimal "24 - New Rights",                                              :precision => 39, :scale => 4
    t.decimal "26 - People's Party count",                                    :precision => 32, :scale => 0
    t.decimal "26 - People's Party",                                          :precision => 39, :scale => 4
    t.decimal "30 - Merab Kostava Society count",                             :precision => 32, :scale => 0
    t.decimal "30 - Merab Kostava Society",                                   :precision => 39, :scale => 4
    t.decimal "35 - Future Georgia count",                                    :precision => 32, :scale => 0
    t.decimal "35 - Future Georgia",                                          :precision => 39, :scale => 4
    t.decimal "36 - Labour Council of Georgia count",                         :precision => 32, :scale => 0
    t.decimal "36 - Labour Council of Georgia",                               :precision => 39, :scale => 4
    t.decimal "38 - Labour count",                                            :precision => 32, :scale => 0
    t.decimal "38 - Labour",                                                  :precision => 39, :scale => 4
    t.decimal "40 - Sportsman's Union count",                                 :precision => 32, :scale => 0
    t.decimal "40 - Sportsman's Union",                                       :precision => 39, :scale => 4
    t.decimal "41 - Georgian Dream count",                                    :precision => 32, :scale => 0
    t.decimal "41 - Georgian Dream",                                          :precision => 39, :scale => 4
  end

  create_table "2012_parliamentary_party_list - tbilisi precinct", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.string  "district_Name"
    t.integer "precinct_id"
    t.string  "precinct_name",                                  :limit => 23
    t.integer "possible voters"
    t.integer "total ballots cast"
    t.integer "total valid ballots cast"
    t.decimal "percent invalid ballots",                                      :precision => 17, :scale => 4
    t.decimal "percent voters voting",                                        :precision => 17, :scale => 4
    t.integer "logic_check_fail"
    t.integer "logic_check_difference"
    t.integer "more_ballots_than_votes_flag"
    t.integer "more_ballots_than_votes"
    t.integer "more_votes_than_ballots_flag"
    t.integer "more_votes_than_ballots"
    t.integer "votes 8-12"
    t.integer "votes 12-17",                                    :limit => 8
    t.integer "votes 17-20",                                    :limit => 8
    t.decimal "vpm 8-12",                                                     :precision => 14, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 15, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 15, :scale => 4
    t.integer "1 - Free Georgia count"
    t.decimal "1 - Free Georgia",                                             :precision => 17, :scale => 4
    t.integer "4 - National Democratic Party of Georgia count"
    t.decimal "4 - National Democratic Party of Georgia",                     :precision => 17, :scale => 4
    t.integer "5 - United National Movement count"
    t.decimal "5 - United National Movement",                                 :precision => 17, :scale => 4
    t.integer "9 - Movement for Fair Georgia count"
    t.decimal "9 - Movement for Fair Georgia",                                :precision => 17, :scale => 4
    t.integer "10 - Christian-Democratic Movement count"
    t.decimal "10 - Christian-Democratic Movement",                           :precision => 17, :scale => 4
    t.integer "17 - Public Movement count"
    t.decimal "17 - Public Movement",                                         :precision => 17, :scale => 4
    t.integer "19 - Freedom Party count"
    t.decimal "19 - Freedom Party",                                           :precision => 17, :scale => 4
    t.integer "23 - Georgian Group count"
    t.decimal "23 - Georgian Group",                                          :precision => 17, :scale => 4
    t.integer "24 - New Rights count"
    t.decimal "24 - New Rights",                                              :precision => 17, :scale => 4
    t.integer "26 - People's Party count"
    t.decimal "26 - People's Party",                                          :precision => 17, :scale => 4
    t.integer "30 - Merab Kostava Society count"
    t.decimal "30 - Merab Kostava Society",                                   :precision => 17, :scale => 4
    t.integer "35 - Future Georgia count"
    t.decimal "35 - Future Georgia",                                          :precision => 17, :scale => 4
    t.integer "36 - Labour Council of Georgia count"
    t.decimal "36 - Labour Council of Georgia",                               :precision => 17, :scale => 4
    t.integer "38 - Labour count"
    t.decimal "38 - Labour",                                                  :precision => 17, :scale => 4
    t.integer "40 - Sportsman's Union count"
    t.decimal "40 - Sportsman's Union",                                       :precision => 17, :scale => 4
    t.integer "41 - Georgian Dream count"
    t.decimal "41 - Georgian Dream",                                          :precision => 17, :scale => 4
  end

  create_table "2012_parliamentary_party_list - vpm 12-17>2", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "vpm > 2",     :limit => 8, :default => 0, :null => false
  end

  create_table "2012_parliamentary_party_list - vpm 17-20>2", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "vpm > 2",     :limit => 8, :default => 0, :null => false
  end

  create_table "2012_parliamentary_party_list - vpm 8-12>2", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "vpm > 2",     :limit => 8, :default => 0, :null => false
  end

  create_table "2013_presidential - country", :id => false, :force => true do |t|
    t.decimal "possible voters",                                              :precision => 32, :scale => 0
    t.decimal "total ballots cast",                                           :precision => 32, :scale => 0
    t.decimal "total valid ballots cast",                                     :precision => 32, :scale => 0
    t.decimal "num invalid ballots from 0-1%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 1-3%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 3-5%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots >5%",                                      :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "percent voters voting",                                        :precision => 39, :scale => 4
    t.decimal "num precincts logic fail",                                     :precision => 32, :scale => 0
    t.decimal "percent precincts logic fail",                                 :precision => 39, :scale => 4
    t.decimal "avg precinct logic fail difference",                           :precision => 36, :scale => 4
    t.decimal "num precincts more ballots than votes",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more ballots than votes",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more ballots than votes",              :precision => 36, :scale => 4
    t.decimal "num precincts more votes than ballots",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more votes than ballots",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more votes than ballots",              :precision => 36, :scale => 4
    t.decimal "votes 8-12",                                                   :precision => 32, :scale => 0
    t.decimal "votes 12-17",                                                  :precision => 33, :scale => 0
    t.decimal "votes 17-20",                                                  :precision => 33, :scale => 0
    t.decimal "avg votes/precinct 8-12",                                      :precision => 36, :scale => 4
    t.decimal "avg votes/precinct 12-17",                                     :precision => 37, :scale => 4
    t.decimal "avg votes/precinct 17-20",                                     :precision => 37, :scale => 4
    t.decimal "vpm 8-12",                                                     :precision => 36, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 37, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 37, :scale => 4
    t.decimal "avg vpm/precinct 8-12",                                        :precision => 40, :scale => 8
    t.decimal "avg vpm/precinct 12-17",                                       :precision => 41, :scale => 8
    t.decimal "avg vpm/precinct 17-20",                                       :precision => 41, :scale => 8
    t.decimal "num precincts vpm 8-12 > 2",                                   :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 12-17 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 17-20 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm > 2",                                        :precision => 44, :scale => 0, :default => 0, :null => false
    t.decimal "num_precincts_possible",                                       :precision => 32, :scale => 0
    t.integer "num_precincts_reported_number",                   :limit => 8,                                :default => 0, :null => false
    t.decimal "num_precincts_reported_percent",                               :precision => 27, :scale => 4
    t.decimal "1 - Tamaz Bibiluri count",                                     :precision => 32, :scale => 0
    t.decimal "1 - Tamaz Bibiluri",                                           :precision => 39, :scale => 4
    t.decimal "2 - Giorgi Liluashvili count",                                 :precision => 32, :scale => 0
    t.decimal "2 - Giorgi Liluashvili",                                       :precision => 39, :scale => 4
    t.decimal "3 - Sergo Javakhidze count",                                   :precision => 32, :scale => 0
    t.decimal "3 - Sergo Javakhidze",                                         :precision => 39, :scale => 4
    t.decimal "4 - Koba Davitashvili count",                                  :precision => 32, :scale => 0
    t.decimal "4 - Koba Davitashvili",                                        :precision => 39, :scale => 4
    t.decimal "5 - Davit Bakradze count",                                     :precision => 32, :scale => 0
    t.decimal "5 - Davit Bakradze",                                           :precision => 39, :scale => 4
    t.decimal "6 - Akaki Asatiani count",                                     :precision => 32, :scale => 0
    t.decimal "6 - Akaki Asatiani",                                           :precision => 39, :scale => 4
    t.decimal "7 - Nino Chanishvili count",                                   :precision => 32, :scale => 0
    t.decimal "7 - Nino Chanishvili",                                         :precision => 39, :scale => 4
    t.decimal "8 - Teimuraz Bobokhidze count",                                :precision => 32, :scale => 0
    t.decimal "8 - Teimuraz Bobokhidze",                                      :precision => 39, :scale => 4
    t.decimal "9 - Shalva Natelashvili count",                                :precision => 32, :scale => 0
    t.decimal "9 - Shalva Natelashvili",                                      :precision => 39, :scale => 4
    t.decimal "10 - Giorgi Targamadze count",                                 :precision => 32, :scale => 0
    t.decimal "10 - Giorgi Targamadze",                                       :precision => 39, :scale => 4
    t.decimal "11 - Levan Chachua count",                                     :precision => 32, :scale => 0
    t.decimal "11 - Levan Chachua",                                           :precision => 39, :scale => 4
    t.decimal "12 - Nestan Kirtadze count",                                   :precision => 32, :scale => 0
    t.decimal "12 - Nestan Kirtadze",                                         :precision => 39, :scale => 4
    t.decimal "13 - Giorgi Chikhladze count",                                 :precision => 32, :scale => 0
    t.decimal "13 - Giorgi Chikhladze",                                       :precision => 39, :scale => 4
    t.decimal "14 - Nino Burjanadze count",                                   :precision => 32, :scale => 0
    t.decimal "14 - Nino Burjanadze",                                         :precision => 39, :scale => 4
    t.decimal "15 - Zurab Kharatishvili count",                               :precision => 32, :scale => 0
    t.decimal "15 - Zurab Kharatishvili",                                     :precision => 39, :scale => 4
    t.decimal "16 - Mikheil Saluashvili count",                               :precision => 32, :scale => 0
    t.decimal "16 - Mikheil Saluashvili",                                     :precision => 39, :scale => 4
    t.decimal "17 - Kartlos Gharibashvili count",                             :precision => 32, :scale => 0
    t.decimal "17 - Kartlos Gharibashvili",                                   :precision => 39, :scale => 4
    t.decimal "18 - Mamuka Chokhonelidze count",                              :precision => 32, :scale => 0
    t.decimal "18 - Mamuka Chokhonelidze",                                    :precision => 39, :scale => 4
    t.decimal "19 - Avtandil Margiani count",                                 :precision => 32, :scale => 0
    t.decimal "19 - Avtandil Margiani",                                       :precision => 39, :scale => 4
    t.decimal "20 - Nugzar Avaliani count",                                   :precision => 32, :scale => 0
    t.decimal "20 - Nugzar Avaliani",                                         :precision => 39, :scale => 4
    t.decimal "21 - Mamuka Melikishvili count",                               :precision => 32, :scale => 0
    t.decimal "21 - Mamuka Melikishvili",                                     :precision => 39, :scale => 4
    t.decimal "22 - Teimuraz Mzhavia count",                                  :precision => 32, :scale => 0
    t.decimal "22 - Teimuraz Mzhavia",                                        :precision => 39, :scale => 4
    t.decimal "41 - Giorgi Margvelashvili count",                             :precision => 32, :scale => 0
    t.decimal "41 - Giorgi Margvelashvili",                                   :precision => 39, :scale => 4
  end

  create_table "2013_presidential - csv", :id => false, :force => true do |t|
    t.string  "shape",                                                       :limit => 16,                                :default => "", :null => false
    t.string  "common_id"
    t.string  "common_name"
    t.decimal "Total Voter Turnout (#)",                                                   :precision => 32, :scale => 0
    t.decimal "Total Voter Turnout (%)",                                                   :precision => 39, :scale => 4
    t.decimal "Number of Precincts with Invalid Ballots from 0-1%",                        :precision => 42, :scale => 0
    t.decimal "Number of Precincts with Invalid Ballots from 1-3%",                        :precision => 42, :scale => 0
    t.decimal "Number of Precincts with Invalid Ballots from 3-5%",                        :precision => 42, :scale => 0
    t.decimal "Number of Precincts with Invalid Ballots > 5%",                             :precision => 42, :scale => 0
    t.decimal "Invalid Ballots (%)",                                                       :precision => 17, :scale => 4
    t.decimal "Precincts with More Ballots Than Votes (#)",                                :precision => 32, :scale => 0
    t.decimal "Precincts with More Ballots Than Votes (%)",                                :precision => 39, :scale => 4
    t.decimal "More Ballots Than Votes (Average)",                                         :precision => 36, :scale => 4
    t.integer "More Ballots Than Votes (#)"
    t.decimal "Precincts with More Votes than Ballots (#)",                                :precision => 32, :scale => 0
    t.decimal "Precincts with More Votes than Ballots (%)",                                :precision => 39, :scale => 4
    t.decimal "More Votes than Ballots (Average)",                                         :precision => 36, :scale => 4
    t.integer "More Votes than Ballots (#)"
    t.decimal "Average votes per minute (08:00-12:00)",                                    :precision => 14, :scale => 4
    t.decimal "Average votes per minute (12:00-17:00)",                                    :precision => 15, :scale => 4
    t.decimal "Average votes per minute (17:00-20:00)",                                    :precision => 15, :scale => 4
    t.decimal "Number of Precincts with votes per minute > 2 (08:00-12:00)",               :precision => 42, :scale => 0
    t.decimal "Number of Precincts with votes per minute > 2 (12:00-17:00)",               :precision => 42, :scale => 0
    t.decimal "Number of Precincts with votes per minute > 2 (17:00-20:00)",               :precision => 42, :scale => 0
    t.decimal "Number of Precincts with votes per minute > 2",                             :precision => 44, :scale => 0
    t.integer "Precincts Reported (#)",                                      :limit => 8
    t.decimal "Precincts Reported (%)",                                                    :precision => 27, :scale => 4
    t.decimal "Tamaz Bibiluri",                                                            :precision => 39, :scale => 4
    t.decimal "Giorgi Liluashvili",                                                        :precision => 39, :scale => 4
    t.decimal "Sergo Javakhidze",                                                          :precision => 39, :scale => 4
    t.decimal "Koba Davitashvili",                                                         :precision => 39, :scale => 4
    t.decimal "Davit Bakradze",                                                            :precision => 39, :scale => 4
    t.decimal "Akaki Asatiani",                                                            :precision => 39, :scale => 4
    t.decimal "Nino Chanishvili",                                                          :precision => 39, :scale => 4
    t.decimal "Teimuraz Bobokhidze",                                                       :precision => 39, :scale => 4
    t.decimal "Shalva Natelashvili",                                                       :precision => 39, :scale => 4
    t.decimal "Giorgi Targamadze",                                                         :precision => 39, :scale => 4
    t.decimal "Levan Chachua",                                                             :precision => 39, :scale => 4
    t.decimal "Nestan Kirtadze",                                                           :precision => 39, :scale => 4
    t.decimal "Giorgi Chikhladze",                                                         :precision => 39, :scale => 4
    t.decimal "Nino Burjanadze",                                                           :precision => 39, :scale => 4
    t.decimal "Zurab Kharatishvili",                                                       :precision => 39, :scale => 4
    t.decimal "Mikheil Saluashvili",                                                       :precision => 39, :scale => 4
    t.decimal "Kartlos Gharibashvili",                                                     :precision => 39, :scale => 4
    t.decimal "Mamuka Chokhonelidze",                                                      :precision => 39, :scale => 4
    t.decimal "Avtandil Margiani",                                                         :precision => 39, :scale => 4
    t.decimal "Nugzar Avaliani",                                                           :precision => 39, :scale => 4
    t.decimal "Mamuka Melikishvili",                                                       :precision => 39, :scale => 4
    t.decimal "Teimuraz Mzhavia",                                                          :precision => 39, :scale => 4
    t.decimal "Giorgi Margvelashvili",                                                     :precision => 39, :scale => 4
  end

  create_table "2013_presidential - district", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id",                                     :limit => 8
    t.string  "district_Name"
    t.decimal "possible voters",                                              :precision => 32, :scale => 0
    t.decimal "total ballots cast",                                           :precision => 32, :scale => 0
    t.decimal "total valid ballots cast",                                     :precision => 32, :scale => 0
    t.decimal "num invalid ballots from 0-1%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 1-3%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 3-5%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots >5%",                                      :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "percent voters voting",                                        :precision => 39, :scale => 4
    t.decimal "num precincts logic fail",                                     :precision => 32, :scale => 0
    t.decimal "percent precincts logic fail",                                 :precision => 39, :scale => 4
    t.decimal "avg precinct logic fail difference",                           :precision => 36, :scale => 4
    t.decimal "num precincts more ballots than votes",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more ballots than votes",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more ballots than votes",              :precision => 36, :scale => 4
    t.decimal "num precincts more votes than ballots",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more votes than ballots",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more votes than ballots",              :precision => 36, :scale => 4
    t.decimal "votes 8-12",                                                   :precision => 32, :scale => 0
    t.decimal "votes 12-17",                                                  :precision => 33, :scale => 0
    t.decimal "votes 17-20",                                                  :precision => 33, :scale => 0
    t.decimal "avg votes/precinct 8-12",                                      :precision => 36, :scale => 4
    t.decimal "avg votes/precinct 12-17",                                     :precision => 37, :scale => 4
    t.decimal "avg votes/precinct 17-20",                                     :precision => 37, :scale => 4
    t.decimal "vpm 8-12",                                                     :precision => 36, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 37, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 37, :scale => 4
    t.decimal "avg vpm/precinct 8-12",                                        :precision => 40, :scale => 8
    t.decimal "avg vpm/precinct 12-17",                                       :precision => 41, :scale => 8
    t.decimal "avg vpm/precinct 17-20",                                       :precision => 41, :scale => 8
    t.decimal "num precincts vpm 8-12 > 2",                                   :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 12-17 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 17-20 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm > 2",                                        :precision => 44, :scale => 0, :default => 0, :null => false
    t.decimal "num_precincts_possible",                                       :precision => 32, :scale => 0
    t.integer "num_precincts_reported_number",                   :limit => 8,                                :default => 0, :null => false
    t.decimal "num_precincts_reported_percent",                               :precision => 27, :scale => 4
    t.decimal "1 - Tamaz Bibiluri count",                                     :precision => 32, :scale => 0
    t.decimal "1 - Tamaz Bibiluri",                                           :precision => 39, :scale => 4
    t.decimal "2 - Giorgi Liluashvili count",                                 :precision => 32, :scale => 0
    t.decimal "2 - Giorgi Liluashvili",                                       :precision => 39, :scale => 4
    t.decimal "3 - Sergo Javakhidze count",                                   :precision => 32, :scale => 0
    t.decimal "3 - Sergo Javakhidze",                                         :precision => 39, :scale => 4
    t.decimal "4 - Koba Davitashvili count",                                  :precision => 32, :scale => 0
    t.decimal "4 - Koba Davitashvili",                                        :precision => 39, :scale => 4
    t.decimal "5 - Davit Bakradze count",                                     :precision => 32, :scale => 0
    t.decimal "5 - Davit Bakradze",                                           :precision => 39, :scale => 4
    t.decimal "6 - Akaki Asatiani count",                                     :precision => 32, :scale => 0
    t.decimal "6 - Akaki Asatiani",                                           :precision => 39, :scale => 4
    t.decimal "7 - Nino Chanishvili count",                                   :precision => 32, :scale => 0
    t.decimal "7 - Nino Chanishvili",                                         :precision => 39, :scale => 4
    t.decimal "8 - Teimuraz Bobokhidze count",                                :precision => 32, :scale => 0
    t.decimal "8 - Teimuraz Bobokhidze",                                      :precision => 39, :scale => 4
    t.decimal "9 - Shalva Natelashvili count",                                :precision => 32, :scale => 0
    t.decimal "9 - Shalva Natelashvili",                                      :precision => 39, :scale => 4
    t.decimal "10 - Giorgi Targamadze count",                                 :precision => 32, :scale => 0
    t.decimal "10 - Giorgi Targamadze",                                       :precision => 39, :scale => 4
    t.decimal "11 - Levan Chachua count",                                     :precision => 32, :scale => 0
    t.decimal "11 - Levan Chachua",                                           :precision => 39, :scale => 4
    t.decimal "12 - Nestan Kirtadze count",                                   :precision => 32, :scale => 0
    t.decimal "12 - Nestan Kirtadze",                                         :precision => 39, :scale => 4
    t.decimal "13 - Giorgi Chikhladze count",                                 :precision => 32, :scale => 0
    t.decimal "13 - Giorgi Chikhladze",                                       :precision => 39, :scale => 4
    t.decimal "14 - Nino Burjanadze count",                                   :precision => 32, :scale => 0
    t.decimal "14 - Nino Burjanadze",                                         :precision => 39, :scale => 4
    t.decimal "15 - Zurab Kharatishvili count",                               :precision => 32, :scale => 0
    t.decimal "15 - Zurab Kharatishvili",                                     :precision => 39, :scale => 4
    t.decimal "16 - Mikheil Saluashvili count",                               :precision => 32, :scale => 0
    t.decimal "16 - Mikheil Saluashvili",                                     :precision => 39, :scale => 4
    t.decimal "17 - Kartlos Gharibashvili count",                             :precision => 32, :scale => 0
    t.decimal "17 - Kartlos Gharibashvili",                                   :precision => 39, :scale => 4
    t.decimal "18 - Mamuka Chokhonelidze count",                              :precision => 32, :scale => 0
    t.decimal "18 - Mamuka Chokhonelidze",                                    :precision => 39, :scale => 4
    t.decimal "19 - Avtandil Margiani count",                                 :precision => 32, :scale => 0
    t.decimal "19 - Avtandil Margiani",                                       :precision => 39, :scale => 4
    t.decimal "20 - Nugzar Avaliani count",                                   :precision => 32, :scale => 0
    t.decimal "20 - Nugzar Avaliani",                                         :precision => 39, :scale => 4
    t.decimal "21 - Mamuka Melikishvili count",                               :precision => 32, :scale => 0
    t.decimal "21 - Mamuka Melikishvili",                                     :precision => 39, :scale => 4
    t.decimal "22 - Teimuraz Mzhavia count",                                  :precision => 32, :scale => 0
    t.decimal "22 - Teimuraz Mzhavia",                                        :precision => 39, :scale => 4
    t.decimal "41 - Giorgi Margvelashvili count",                             :precision => 32, :scale => 0
    t.decimal "41 - Giorgi Margvelashvili",                                   :precision => 39, :scale => 4
  end

  create_table "2013_presidential - invalid ballots 0-1", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "num_invalid_ballots", :limit => 8, :default => 0, :null => false
  end

  create_table "2013_presidential - invalid ballots 1-3", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "num_invalid_ballots", :limit => 8, :default => 0, :null => false
  end

  create_table "2013_presidential - invalid ballots 3-5", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "num_invalid_ballots", :limit => 8, :default => 0, :null => false
  end

  create_table "2013_presidential - invalid ballots >5", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "num_invalid_ballots", :limit => 8, :default => 0, :null => false
  end

  create_table "2013_presidential - precinct", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.string  "district_Name"
    t.integer "precinct_id"
    t.string  "precinct_name",                    :limit => 23
    t.integer "possible voters"
    t.integer "total ballots cast"
    t.integer "total valid ballots cast"
    t.decimal "percent invalid ballots",                        :precision => 17, :scale => 4
    t.decimal "percent voters voting",                          :precision => 17, :scale => 4
    t.integer "logic_check_fail"
    t.integer "logic_check_difference"
    t.integer "more_ballots_than_votes_flag"
    t.integer "more_ballots_than_votes"
    t.integer "more_votes_than_ballots_flag"
    t.integer "more_votes_than_ballots"
    t.integer "votes 8-12"
    t.integer "votes 12-17",                      :limit => 8
    t.integer "votes 17-20",                      :limit => 8
    t.decimal "vpm 8-12",                                       :precision => 14, :scale => 4
    t.decimal "vpm 12-17",                                      :precision => 15, :scale => 4
    t.decimal "vpm 17-20",                                      :precision => 15, :scale => 4
    t.integer "1 - Tamaz Bibiluri count"
    t.decimal "1 - Tamaz Bibiluri",                             :precision => 17, :scale => 4
    t.integer "2 - Giorgi Liluashvili count"
    t.decimal "2 - Giorgi Liluashvili",                         :precision => 17, :scale => 4
    t.integer "3 - Sergo Javakhidze count"
    t.decimal "3 - Sergo Javakhidze",                           :precision => 17, :scale => 4
    t.integer "4 - Koba Davitashvili count"
    t.decimal "4 - Koba Davitashvili",                          :precision => 17, :scale => 4
    t.integer "5 - Davit Bakradze count"
    t.decimal "5 - Davit Bakradze",                             :precision => 17, :scale => 4
    t.integer "6 - Akaki Asatiani count"
    t.decimal "6 - Akaki Asatiani",                             :precision => 17, :scale => 4
    t.integer "7 - Nino Chanishvili count"
    t.decimal "7 - Nino Chanishvili",                           :precision => 17, :scale => 4
    t.integer "8 - Teimuraz Bobokhidze count"
    t.decimal "8 - Teimuraz Bobokhidze",                        :precision => 17, :scale => 4
    t.integer "9 - Shalva Natelashvili count"
    t.decimal "9 - Shalva Natelashvili",                        :precision => 17, :scale => 4
    t.integer "10 - Giorgi Targamadze count"
    t.decimal "10 - Giorgi Targamadze",                         :precision => 17, :scale => 4
    t.integer "11 - Levan Chachua count"
    t.decimal "11 - Levan Chachua",                             :precision => 17, :scale => 4
    t.integer "12 - Nestan Kirtadze count"
    t.decimal "12 - Nestan Kirtadze",                           :precision => 17, :scale => 4
    t.integer "13 - Giorgi Chikhladze count"
    t.decimal "13 - Giorgi Chikhladze",                         :precision => 17, :scale => 4
    t.integer "14 - Nino Burjanadze count"
    t.decimal "14 - Nino Burjanadze",                           :precision => 17, :scale => 4
    t.integer "15 - Zurab Kharatishvili count"
    t.decimal "15 - Zurab Kharatishvili",                       :precision => 17, :scale => 4
    t.integer "16 - Mikheil Saluashvili count"
    t.decimal "16 - Mikheil Saluashvili",                       :precision => 17, :scale => 4
    t.integer "17 - Kartlos Gharibashvili count"
    t.decimal "17 - Kartlos Gharibashvili",                     :precision => 17, :scale => 4
    t.integer "18 - Mamuka Chokhonelidze count"
    t.decimal "18 - Mamuka Chokhonelidze",                      :precision => 17, :scale => 4
    t.integer "19 - Avtandil Margiani count"
    t.decimal "19 - Avtandil Margiani",                         :precision => 17, :scale => 4
    t.integer "20 - Nugzar Avaliani count"
    t.decimal "20 - Nugzar Avaliani",                           :precision => 17, :scale => 4
    t.integer "21 - Mamuka Melikishvili count"
    t.decimal "21 - Mamuka Melikishvili",                       :precision => 17, :scale => 4
    t.integer "22 - Teimuraz Mzhavia count"
    t.decimal "22 - Teimuraz Mzhavia",                          :precision => 17, :scale => 4
    t.integer "41 - Giorgi Margvelashvili count"
    t.decimal "41 - Giorgi Margvelashvili",                     :precision => 17, :scale => 4
  end

  create_table "2013_presidential - precinct count", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id",   :default => 0, :null => false
    t.integer "num_precincts"
  end

  add_index "2013_presidential - precinct count", ["district_id"], :name => "district"
  add_index "2013_presidential - precinct count", ["region"], :name => "region"

  create_table "2013_presidential - precinct count by country", :id => false, :force => true do |t|
    t.decimal "num_precincts", :precision => 32, :scale => 0
  end

  create_table "2013_presidential - precinct count by district", :id => false, :force => true do |t|
    t.integer "district_id",                                  :default => 0, :null => false
    t.decimal "num_precincts", :precision => 32, :scale => 0
  end

  create_table "2013_presidential - precinct count by region", :id => false, :force => true do |t|
    t.string  "region"
    t.decimal "num_precincts", :precision => 32, :scale => 0
  end

  create_table "2013_presidential - raw", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.string  "district_name"
    t.integer "precinct_id"
    t.integer "attached_precinct_id"
    t.integer "num_possible_voters"
    t.integer "num_special_voters"
    t.integer "num_at_12"
    t.integer "num_at_17"
    t.integer "num_votes"
    t.integer "num_ballots"
    t.integer "num_invalid_votes"
    t.integer "num_valid_votes"
    t.integer "logic_check_fail"
    t.integer "logic_check_difference"
    t.integer "more_ballots_than_votes_flag"
    t.integer "more_ballots_than_votes"
    t.integer "more_votes_than_ballots_flag"
    t.integer "more_votes_than_ballots"
    t.integer "1 - Tamaz Bibiluri"
    t.integer "2 - Giorgi Liluashvili"
    t.integer "3 - Sergo Javakhidze"
    t.integer "4 - Koba Davitashvili"
    t.integer "5 - Davit Bakradze"
    t.integer "6 - Akaki Asatiani"
    t.integer "7 - Nino Chanishvili"
    t.integer "8 - Teimuraz Bobokhidze"
    t.integer "9 - Shalva Natelashvili"
    t.integer "10 - Giorgi Targamadze"
    t.integer "11 - Levan Chachua"
    t.integer "12 - Nestan Kirtadze"
    t.integer "13 - Giorgi Chikhladze"
    t.integer "14 - Nino Burjanadze"
    t.integer "15 - Zurab Kharatishvili"
    t.integer "16 - Mikheil Saluashvili"
    t.integer "17 - Kartlos Gharibashvili"
    t.integer "18 - Mamuka Chokhonelidze"
    t.integer "19 - Avtandil Margiani"
    t.integer "20 - Nugzar Avaliani"
    t.integer "21 - Mamuka Melikishvili"
    t.integer "22 - Teimuraz Mzhavia"
    t.integer "41 - Giorgi Margvelashvili"
  end

  create_table "2013_presidential - region", :id => false, :force => true do |t|
    t.string  "region"
    t.decimal "possible voters",                                              :precision => 32, :scale => 0
    t.decimal "total ballots cast",                                           :precision => 32, :scale => 0
    t.decimal "total valid ballots cast",                                     :precision => 32, :scale => 0
    t.decimal "num invalid ballots from 0-1%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 1-3%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 3-5%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots >5%",                                      :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "percent voters voting",                                        :precision => 39, :scale => 4
    t.decimal "num precincts logic fail",                                     :precision => 32, :scale => 0
    t.decimal "percent precincts logic fail",                                 :precision => 39, :scale => 4
    t.decimal "avg precinct logic fail difference",                           :precision => 36, :scale => 4
    t.decimal "num precincts more ballots than votes",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more ballots than votes",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more ballots than votes",              :precision => 36, :scale => 4
    t.decimal "num precincts more votes than ballots",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more votes than ballots",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more votes than ballots",              :precision => 36, :scale => 4
    t.decimal "votes 8-12",                                                   :precision => 32, :scale => 0
    t.decimal "votes 12-17",                                                  :precision => 33, :scale => 0
    t.decimal "votes 17-20",                                                  :precision => 33, :scale => 0
    t.decimal "avg votes/precinct 8-12",                                      :precision => 36, :scale => 4
    t.decimal "avg votes/precinct 12-17",                                     :precision => 37, :scale => 4
    t.decimal "avg votes/precinct 17-20",                                     :precision => 37, :scale => 4
    t.decimal "vpm 8-12",                                                     :precision => 36, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 37, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 37, :scale => 4
    t.decimal "avg vpm/precinct 8-12",                                        :precision => 40, :scale => 8
    t.decimal "avg vpm/precinct 12-17",                                       :precision => 41, :scale => 8
    t.decimal "avg vpm/precinct 17-20",                                       :precision => 41, :scale => 8
    t.decimal "num precincts vpm 8-12 > 2",                                   :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 12-17 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 17-20 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm > 2",                                        :precision => 44, :scale => 0, :default => 0, :null => false
    t.decimal "num_precincts_possible",                                       :precision => 32, :scale => 0
    t.integer "num_precincts_reported_number",                   :limit => 8,                                :default => 0, :null => false
    t.decimal "num_precincts_reported_percent",                               :precision => 27, :scale => 4
    t.decimal "1 - Tamaz Bibiluri count",                                     :precision => 32, :scale => 0
    t.decimal "1 - Tamaz Bibiluri",                                           :precision => 39, :scale => 4
    t.decimal "2 - Giorgi Liluashvili count",                                 :precision => 32, :scale => 0
    t.decimal "2 - Giorgi Liluashvili",                                       :precision => 39, :scale => 4
    t.decimal "3 - Sergo Javakhidze count",                                   :precision => 32, :scale => 0
    t.decimal "3 - Sergo Javakhidze",                                         :precision => 39, :scale => 4
    t.decimal "4 - Koba Davitashvili count",                                  :precision => 32, :scale => 0
    t.decimal "4 - Koba Davitashvili",                                        :precision => 39, :scale => 4
    t.decimal "5 - Davit Bakradze count",                                     :precision => 32, :scale => 0
    t.decimal "5 - Davit Bakradze",                                           :precision => 39, :scale => 4
    t.decimal "6 - Akaki Asatiani count",                                     :precision => 32, :scale => 0
    t.decimal "6 - Akaki Asatiani",                                           :precision => 39, :scale => 4
    t.decimal "7 - Nino Chanishvili count",                                   :precision => 32, :scale => 0
    t.decimal "7 - Nino Chanishvili",                                         :precision => 39, :scale => 4
    t.decimal "8 - Teimuraz Bobokhidze count",                                :precision => 32, :scale => 0
    t.decimal "8 - Teimuraz Bobokhidze",                                      :precision => 39, :scale => 4
    t.decimal "9 - Shalva Natelashvili count",                                :precision => 32, :scale => 0
    t.decimal "9 - Shalva Natelashvili",                                      :precision => 39, :scale => 4
    t.decimal "10 - Giorgi Targamadze count",                                 :precision => 32, :scale => 0
    t.decimal "10 - Giorgi Targamadze",                                       :precision => 39, :scale => 4
    t.decimal "11 - Levan Chachua count",                                     :precision => 32, :scale => 0
    t.decimal "11 - Levan Chachua",                                           :precision => 39, :scale => 4
    t.decimal "12 - Nestan Kirtadze count",                                   :precision => 32, :scale => 0
    t.decimal "12 - Nestan Kirtadze",                                         :precision => 39, :scale => 4
    t.decimal "13 - Giorgi Chikhladze count",                                 :precision => 32, :scale => 0
    t.decimal "13 - Giorgi Chikhladze",                                       :precision => 39, :scale => 4
    t.decimal "14 - Nino Burjanadze count",                                   :precision => 32, :scale => 0
    t.decimal "14 - Nino Burjanadze",                                         :precision => 39, :scale => 4
    t.decimal "15 - Zurab Kharatishvili count",                               :precision => 32, :scale => 0
    t.decimal "15 - Zurab Kharatishvili",                                     :precision => 39, :scale => 4
    t.decimal "16 - Mikheil Saluashvili count",                               :precision => 32, :scale => 0
    t.decimal "16 - Mikheil Saluashvili",                                     :precision => 39, :scale => 4
    t.decimal "17 - Kartlos Gharibashvili count",                             :precision => 32, :scale => 0
    t.decimal "17 - Kartlos Gharibashvili",                                   :precision => 39, :scale => 4
    t.decimal "18 - Mamuka Chokhonelidze count",                              :precision => 32, :scale => 0
    t.decimal "18 - Mamuka Chokhonelidze",                                    :precision => 39, :scale => 4
    t.decimal "19 - Avtandil Margiani count",                                 :precision => 32, :scale => 0
    t.decimal "19 - Avtandil Margiani",                                       :precision => 39, :scale => 4
    t.decimal "20 - Nugzar Avaliani count",                                   :precision => 32, :scale => 0
    t.decimal "20 - Nugzar Avaliani",                                         :precision => 39, :scale => 4
    t.decimal "21 - Mamuka Melikishvili count",                               :precision => 32, :scale => 0
    t.decimal "21 - Mamuka Melikishvili",                                     :precision => 39, :scale => 4
    t.decimal "22 - Teimuraz Mzhavia count",                                  :precision => 32, :scale => 0
    t.decimal "22 - Teimuraz Mzhavia",                                        :precision => 39, :scale => 4
    t.decimal "41 - Giorgi Margvelashvili count",                             :precision => 32, :scale => 0
    t.decimal "41 - Giorgi Margvelashvili",                                   :precision => 39, :scale => 4
  end

  create_table "2013_presidential - tbilisi district", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.string  "district_Name"
    t.decimal "possible voters",                                              :precision => 32, :scale => 0
    t.decimal "total ballots cast",                                           :precision => 32, :scale => 0
    t.decimal "total valid ballots cast",                                     :precision => 32, :scale => 0
    t.decimal "num invalid ballots from 0-1%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 1-3%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots from 3-5%",                                :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num invalid ballots >5%",                                      :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "percent voters voting",                                        :precision => 39, :scale => 4
    t.decimal "num precincts logic fail",                                     :precision => 32, :scale => 0
    t.decimal "percent precincts logic fail",                                 :precision => 39, :scale => 4
    t.decimal "avg precinct logic fail difference",                           :precision => 36, :scale => 4
    t.decimal "num precincts more ballots than votes",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more ballots than votes",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more ballots than votes",              :precision => 36, :scale => 4
    t.decimal "num precincts more votes than ballots",                        :precision => 32, :scale => 0
    t.decimal "percent precincts more votes than ballots",                    :precision => 39, :scale => 4
    t.decimal "avg precinct difference more votes than ballots",              :precision => 36, :scale => 4
    t.decimal "votes 8-12",                                                   :precision => 32, :scale => 0
    t.decimal "votes 12-17",                                                  :precision => 33, :scale => 0
    t.decimal "votes 17-20",                                                  :precision => 33, :scale => 0
    t.decimal "avg votes/precinct 8-12",                                      :precision => 36, :scale => 4
    t.decimal "avg votes/precinct 12-17",                                     :precision => 37, :scale => 4
    t.decimal "avg votes/precinct 17-20",                                     :precision => 37, :scale => 4
    t.decimal "vpm 8-12",                                                     :precision => 36, :scale => 4
    t.decimal "vpm 12-17",                                                    :precision => 37, :scale => 4
    t.decimal "vpm 17-20",                                                    :precision => 37, :scale => 4
    t.decimal "avg vpm/precinct 8-12",                                        :precision => 40, :scale => 8
    t.decimal "avg vpm/precinct 12-17",                                       :precision => 41, :scale => 8
    t.decimal "avg vpm/precinct 17-20",                                       :precision => 41, :scale => 8
    t.decimal "num precincts vpm 8-12 > 2",                                   :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 12-17 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm 17-20 > 2",                                  :precision => 42, :scale => 0, :default => 0, :null => false
    t.decimal "num precincts vpm > 2",                                        :precision => 44, :scale => 0, :default => 0, :null => false
    t.decimal "num_precincts_possible",                                       :precision => 32, :scale => 0
    t.integer "num_precincts_reported_number",                   :limit => 8,                                :default => 0, :null => false
    t.decimal "num_precincts_reported_percent",                               :precision => 27, :scale => 4
    t.decimal "1 - Tamaz Bibiluri count",                                     :precision => 32, :scale => 0
    t.decimal "1 - Tamaz Bibiluri",                                           :precision => 39, :scale => 4
    t.decimal "2 - Giorgi Liluashvili count",                                 :precision => 32, :scale => 0
    t.decimal "2 - Giorgi Liluashvili",                                       :precision => 39, :scale => 4
    t.decimal "3 - Sergo Javakhidze count",                                   :precision => 32, :scale => 0
    t.decimal "3 - Sergo Javakhidze",                                         :precision => 39, :scale => 4
    t.decimal "4 - Koba Davitashvili count",                                  :precision => 32, :scale => 0
    t.decimal "4 - Koba Davitashvili",                                        :precision => 39, :scale => 4
    t.decimal "5 - Davit Bakradze count",                                     :precision => 32, :scale => 0
    t.decimal "5 - Davit Bakradze",                                           :precision => 39, :scale => 4
    t.decimal "6 - Akaki Asatiani count",                                     :precision => 32, :scale => 0
    t.decimal "6 - Akaki Asatiani",                                           :precision => 39, :scale => 4
    t.decimal "7 - Nino Chanishvili count",                                   :precision => 32, :scale => 0
    t.decimal "7 - Nino Chanishvili",                                         :precision => 39, :scale => 4
    t.decimal "8 - Teimuraz Bobokhidze count",                                :precision => 32, :scale => 0
    t.decimal "8 - Teimuraz Bobokhidze",                                      :precision => 39, :scale => 4
    t.decimal "9 - Shalva Natelashvili count",                                :precision => 32, :scale => 0
    t.decimal "9 - Shalva Natelashvili",                                      :precision => 39, :scale => 4
    t.decimal "10 - Giorgi Targamadze count",                                 :precision => 32, :scale => 0
    t.decimal "10 - Giorgi Targamadze",                                       :precision => 39, :scale => 4
    t.decimal "11 - Levan Chachua count",                                     :precision => 32, :scale => 0
    t.decimal "11 - Levan Chachua",                                           :precision => 39, :scale => 4
    t.decimal "12 - Nestan Kirtadze count",                                   :precision => 32, :scale => 0
    t.decimal "12 - Nestan Kirtadze",                                         :precision => 39, :scale => 4
    t.decimal "13 - Giorgi Chikhladze count",                                 :precision => 32, :scale => 0
    t.decimal "13 - Giorgi Chikhladze",                                       :precision => 39, :scale => 4
    t.decimal "14 - Nino Burjanadze count",                                   :precision => 32, :scale => 0
    t.decimal "14 - Nino Burjanadze",                                         :precision => 39, :scale => 4
    t.decimal "15 - Zurab Kharatishvili count",                               :precision => 32, :scale => 0
    t.decimal "15 - Zurab Kharatishvili",                                     :precision => 39, :scale => 4
    t.decimal "16 - Mikheil Saluashvili count",                               :precision => 32, :scale => 0
    t.decimal "16 - Mikheil Saluashvili",                                     :precision => 39, :scale => 4
    t.decimal "17 - Kartlos Gharibashvili count",                             :precision => 32, :scale => 0
    t.decimal "17 - Kartlos Gharibashvili",                                   :precision => 39, :scale => 4
    t.decimal "18 - Mamuka Chokhonelidze count",                              :precision => 32, :scale => 0
    t.decimal "18 - Mamuka Chokhonelidze",                                    :precision => 39, :scale => 4
    t.decimal "19 - Avtandil Margiani count",                                 :precision => 32, :scale => 0
    t.decimal "19 - Avtandil Margiani",                                       :precision => 39, :scale => 4
    t.decimal "20 - Nugzar Avaliani count",                                   :precision => 32, :scale => 0
    t.decimal "20 - Nugzar Avaliani",                                         :precision => 39, :scale => 4
    t.decimal "21 - Mamuka Melikishvili count",                               :precision => 32, :scale => 0
    t.decimal "21 - Mamuka Melikishvili",                                     :precision => 39, :scale => 4
    t.decimal "22 - Teimuraz Mzhavia count",                                  :precision => 32, :scale => 0
    t.decimal "22 - Teimuraz Mzhavia",                                        :precision => 39, :scale => 4
    t.decimal "41 - Giorgi Margvelashvili count",                             :precision => 32, :scale => 0
    t.decimal "41 - Giorgi Margvelashvili",                                   :precision => 39, :scale => 4
  end

  create_table "2013_presidential - tbilisi precinct", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.string  "district_Name"
    t.integer "precinct_id"
    t.string  "precinct_name",                    :limit => 23
    t.integer "possible voters"
    t.integer "total ballots cast"
    t.integer "total valid ballots cast"
    t.decimal "percent invalid ballots",                        :precision => 17, :scale => 4
    t.decimal "percent voters voting",                          :precision => 17, :scale => 4
    t.integer "logic_check_fail"
    t.integer "logic_check_difference"
    t.integer "more_ballots_than_votes_flag"
    t.integer "more_ballots_than_votes"
    t.integer "more_votes_than_ballots_flag"
    t.integer "more_votes_than_ballots"
    t.integer "votes 8-12"
    t.integer "votes 12-17",                      :limit => 8
    t.integer "votes 17-20",                      :limit => 8
    t.decimal "vpm 8-12",                                       :precision => 14, :scale => 4
    t.decimal "vpm 12-17",                                      :precision => 15, :scale => 4
    t.decimal "vpm 17-20",                                      :precision => 15, :scale => 4
    t.integer "1 - Tamaz Bibiluri count"
    t.decimal "1 - Tamaz Bibiluri",                             :precision => 17, :scale => 4
    t.integer "2 - Giorgi Liluashvili count"
    t.decimal "2 - Giorgi Liluashvili",                         :precision => 17, :scale => 4
    t.integer "3 - Sergo Javakhidze count"
    t.decimal "3 - Sergo Javakhidze",                           :precision => 17, :scale => 4
    t.integer "4 - Koba Davitashvili count"
    t.decimal "4 - Koba Davitashvili",                          :precision => 17, :scale => 4
    t.integer "5 - Davit Bakradze count"
    t.decimal "5 - Davit Bakradze",                             :precision => 17, :scale => 4
    t.integer "6 - Akaki Asatiani count"
    t.decimal "6 - Akaki Asatiani",                             :precision => 17, :scale => 4
    t.integer "7 - Nino Chanishvili count"
    t.decimal "7 - Nino Chanishvili",                           :precision => 17, :scale => 4
    t.integer "8 - Teimuraz Bobokhidze count"
    t.decimal "8 - Teimuraz Bobokhidze",                        :precision => 17, :scale => 4
    t.integer "9 - Shalva Natelashvili count"
    t.decimal "9 - Shalva Natelashvili",                        :precision => 17, :scale => 4
    t.integer "10 - Giorgi Targamadze count"
    t.decimal "10 - Giorgi Targamadze",                         :precision => 17, :scale => 4
    t.integer "11 - Levan Chachua count"
    t.decimal "11 - Levan Chachua",                             :precision => 17, :scale => 4
    t.integer "12 - Nestan Kirtadze count"
    t.decimal "12 - Nestan Kirtadze",                           :precision => 17, :scale => 4
    t.integer "13 - Giorgi Chikhladze count"
    t.decimal "13 - Giorgi Chikhladze",                         :precision => 17, :scale => 4
    t.integer "14 - Nino Burjanadze count"
    t.decimal "14 - Nino Burjanadze",                           :precision => 17, :scale => 4
    t.integer "15 - Zurab Kharatishvili count"
    t.decimal "15 - Zurab Kharatishvili",                       :precision => 17, :scale => 4
    t.integer "16 - Mikheil Saluashvili count"
    t.decimal "16 - Mikheil Saluashvili",                       :precision => 17, :scale => 4
    t.integer "17 - Kartlos Gharibashvili count"
    t.decimal "17 - Kartlos Gharibashvili",                     :precision => 17, :scale => 4
    t.integer "18 - Mamuka Chokhonelidze count"
    t.decimal "18 - Mamuka Chokhonelidze",                      :precision => 17, :scale => 4
    t.integer "19 - Avtandil Margiani count"
    t.decimal "19 - Avtandil Margiani",                         :precision => 17, :scale => 4
    t.integer "20 - Nugzar Avaliani count"
    t.decimal "20 - Nugzar Avaliani",                           :precision => 17, :scale => 4
    t.integer "21 - Mamuka Melikishvili count"
    t.decimal "21 - Mamuka Melikishvili",                       :precision => 17, :scale => 4
    t.integer "22 - Teimuraz Mzhavia count"
    t.decimal "22 - Teimuraz Mzhavia",                          :precision => 17, :scale => 4
    t.integer "41 - Giorgi Margvelashvili count"
    t.decimal "41 - Giorgi Margvelashvili",                     :precision => 17, :scale => 4
  end

  create_table "2013_presidential - vpm 12-17>2", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "vpm > 2",     :limit => 8, :default => 0, :null => false
  end

  create_table "2013_presidential - vpm 17-20>2", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "vpm > 2",     :limit => 8, :default => 0, :null => false
  end

  create_table "2013_presidential - vpm 8-12>2", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.integer "precinct_id"
    t.integer "vpm > 2",     :limit => 8, :default => 0, :null => false
  end

  create_table "crowd_data", :force => true do |t|
    t.integer  "election_id"
    t.integer  "district_id",               :limit => 2
    t.integer  "precinct_id",               :limit => 2
    t.integer  "user_id"
    t.integer  "possible_voters",           :limit => 3
    t.integer  "special_voters",            :limit => 3
    t.integer  "votes_by_1200",             :limit => 3
    t.integer  "votes_by_1700",             :limit => 3
    t.integer  "ballots_signed_for",        :limit => 3
    t.integer  "ballots_available",         :limit => 3
    t.integer  "invalid_ballots_submitted", :limit => 3
    t.integer  "party_1",                   :limit => 3
    t.integer  "party_2",                   :limit => 3
    t.integer  "party_3",                   :limit => 3
    t.integer  "party_4",                   :limit => 3
    t.integer  "party_5",                   :limit => 3
    t.integer  "party_6",                   :limit => 3
    t.integer  "party_7",                   :limit => 3
    t.integer  "party_8",                   :limit => 3
    t.integer  "party_9",                   :limit => 3
    t.integer  "party_10",                  :limit => 3
    t.integer  "party_11",                  :limit => 3
    t.integer  "party_12",                  :limit => 3
    t.integer  "party_13",                  :limit => 3
    t.integer  "party_14",                  :limit => 3
    t.integer  "party_15",                  :limit => 3
    t.integer  "party_16",                  :limit => 3
    t.integer  "party_17",                  :limit => 3
    t.integer  "party_18",                  :limit => 3
    t.integer  "party_19",                  :limit => 3
    t.integer  "party_20",                  :limit => 3
    t.integer  "party_21",                  :limit => 3
    t.integer  "party_22",                  :limit => 3
    t.integer  "party_23",                  :limit => 3
    t.integer  "party_24",                  :limit => 3
    t.integer  "party_25",                  :limit => 3
    t.integer  "party_26",                  :limit => 3
    t.integer  "party_27",                  :limit => 3
    t.integer  "party_28",                  :limit => 3
    t.integer  "party_29",                  :limit => 3
    t.integer  "party_30",                  :limit => 3
    t.integer  "party_31",                  :limit => 3
    t.integer  "party_32",                  :limit => 3
    t.integer  "party_33",                  :limit => 3
    t.integer  "party_34",                  :limit => 3
    t.integer  "party_35",                  :limit => 3
    t.integer  "party_36",                  :limit => 3
    t.integer  "party_37",                  :limit => 3
    t.integer  "party_38",                  :limit => 3
    t.integer  "party_39",                  :limit => 3
    t.integer  "party_40",                  :limit => 3
    t.integer  "party_41",                  :limit => 3
    t.integer  "party_42",                  :limit => 3
    t.integer  "party_43",                  :limit => 3
    t.integer  "party_44",                  :limit => 3
    t.integer  "party_45",                  :limit => 3
    t.integer  "party_46",                  :limit => 3
    t.integer  "party_47",                  :limit => 3
    t.integer  "party_48",                  :limit => 3
    t.integer  "party_49",                  :limit => 3
    t.integer  "party_50",                  :limit => 3
    t.integer  "party_51",                  :limit => 3
    t.integer  "party_52",                  :limit => 3
    t.integer  "party_53",                  :limit => 3
    t.integer  "party_54",                  :limit => 3
    t.integer  "party_55",                  :limit => 3
    t.integer  "party_56",                  :limit => 3
    t.integer  "party_57",                  :limit => 3
    t.integer  "party_58",                  :limit => 3
    t.integer  "party_59",                  :limit => 3
    t.integer  "party_60",                  :limit => 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_valid"
    t.boolean  "is_extra",                               :default => false
  end

  add_index "crowd_data", ["election_id", "district_id", "precinct_id"], :name => "idx_election_location"
  add_index "crowd_data", ["is_extra"], :name => "index_crowd_data_on_is_extra"
  add_index "crowd_data", ["is_valid"], :name => "index_crowd_data_on_is_valid"
  add_index "crowd_data", ["user_id"], :name => "index_crowd_data_on_user_id"

  create_table "crowd_data_orig", :force => true do |t|
    t.integer  "district_id"
    t.integer  "precinct_id"
    t.integer  "user_id"
    t.integer  "possible_voters"
    t.integer  "special_voters"
    t.integer  "votes_by_1200"
    t.integer  "votes_by_1700"
    t.integer  "ballots_signed_for"
    t.integer  "ballots_available"
    t.integer  "invalid_ballots_submitted"
    t.integer  "party_1"
    t.integer  "party_2"
    t.integer  "party_3"
    t.integer  "party_4"
    t.integer  "party_5"
    t.integer  "party_6"
    t.integer  "party_7"
    t.integer  "party_8"
    t.integer  "party_9"
    t.integer  "party_10"
    t.integer  "party_11"
    t.integer  "party_12"
    t.integer  "party_13"
    t.integer  "party_14"
    t.integer  "party_15"
    t.integer  "party_16"
    t.integer  "party_17"
    t.integer  "party_18"
    t.integer  "party_19"
    t.integer  "party_20"
    t.integer  "party_21"
    t.integer  "party_22"
    t.integer  "party_41"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_valid"
    t.boolean  "is_extra",                  :default => false
  end

  add_index "crowd_data_orig", ["district_id", "precinct_id"], :name => "idx_location"
  add_index "crowd_data_orig", ["is_extra"], :name => "index_crowd_data_on_is_extra"
  add_index "crowd_data_orig", ["is_valid"], :name => "index_crowd_data_on_is_valid"
  add_index "crowd_data_orig", ["user_id"], :name => "index_crowd_data_on_user_id"

  create_table "crowd_queues", :force => true do |t|
    t.integer  "user_id"
    t.integer  "district_id"
    t.integer  "precinct_id"
    t.boolean  "is_finished"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "election_id"
  end

  add_index "crowd_queues", ["district_id", "precinct_id"], :name => "idx_queue_ids"
  add_index "crowd_queues", ["election_id", "district_id", "precinct_id"], :name => "idx_election_queue_ids"
  add_index "crowd_queues", ["is_finished"], :name => "index_crowd_queues_on_is_finished"
  add_index "crowd_queues", ["user_id"], :name => "index_crowd_queues_on_user_id"

  create_table "district_parties", :force => true do |t|
    t.integer  "election_id"
    t.integer  "district_id"
    t.integer  "party_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "district_parties", ["election_id", "district_id"], :name => "index_district_parties_on_election_id_and_district_id"

  create_table "district_precincts", :force => true do |t|
    t.integer  "district_id"
    t.integer  "precinct_id"
    t.boolean  "has_protocol",  :default => false
    t.boolean  "is_validated",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "has_amendment", :default => false
    t.integer  "election_id"
    t.string   "region"
  end

  add_index "district_precincts", ["district_id", "precinct_id"], :name => "idx_dp_location"
  add_index "district_precincts", ["election_id", "region", "district_id", "precinct_id"], :name => "idx_elec_dist_prec"
  add_index "district_precincts", ["has_amendment"], :name => "index_district_precincts_on_has_amendment"
  add_index "district_precincts", ["has_protocol"], :name => "index_district_precincts_on_has_protocol"
  add_index "district_precincts", ["is_validated"], :name => "index_district_precincts_on_is_validated"

  create_table "election_data_migrations", :force => true do |t|
    t.integer  "num_precincts"
    t.string   "file_name"
    t.datetime "recieved_success_notification_at"
    t.boolean  "success"
    t.string   "notification_msg"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "election_id"
  end

  add_index "election_data_migrations", ["election_id"], :name => "index_election_data_migrations_on_election_id"
  add_index "election_data_migrations", ["file_name"], :name => "index_election_data_migrations_on_file_name"

  create_table "election_translations", :force => true do |t|
    t.integer  "election_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "election_translations", ["election_id"], :name => "index_election_translations_on_election_id"
  add_index "election_translations", ["locale"], :name => "index_election_translations_on_locale"
  add_index "election_translations", ["name"], :name => "index_election_translations_on_name"

  create_table "election_users", :force => true do |t|
    t.integer  "election_id"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "election_users", ["election_id"], :name => "index_election_users_on_election_id"
  add_index "election_users", ["user_id"], :name => "index_election_users_on_user_id"

  create_table "elections", :force => true do |t|
    t.date     "election_at"
    t.integer  "election_app_event_id"
    t.boolean  "can_enter_data",                 :default => false
    t.boolean  "parties_same_for_all_districts", :default => true
    t.boolean  "is_local_majoritarian",          :default => false
    t.boolean  "has_regions",                    :default => false
    t.boolean  "has_district_names",             :default => false
    t.string   "analysis_table_name"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
  end

  add_index "elections", ["can_enter_data"], :name => "index_elections_on_can_enter_data"

  create_table "has_protocols", :force => true do |t|
    t.integer  "district_id"
    t.integer  "precinct_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "election_id"
  end

  add_index "has_protocols", ["district_id", "precinct_id"], :name => "idx_hp_ids"
  add_index "has_protocols", ["election_id", "district_id", "precinct_id"], :name => "idx_election_hp_ids"

  create_table "parties", :force => true do |t|
    t.integer  "election_id"
    t.integer  "number",      :limit => 1
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "parties", ["election_id"], :name => "index_parties_on_election_id"

  create_table "party_translations", :force => true do |t|
    t.integer  "party_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "party_translations", ["locale"], :name => "index_party_translations_on_locale"
  add_index "party_translations", ["name"], :name => "index_party_translations_on_name"
  add_index "party_translations", ["party_id"], :name => "index_party_translations_on_party_id"

  create_table "president2013s", :force => true do |t|
    t.string   "region"
    t.integer  "district_id"
    t.string   "district_name"
    t.integer  "precinct_id"
    t.integer  "attached_precinct_id"
    t.integer  "num_possible_voters"
    t.integer  "num_special_voters"
    t.integer  "num_at_12"
    t.integer  "num_at_17"
    t.integer  "num_votes"
    t.integer  "num_ballots"
    t.integer  "num_invalid_votes"
    t.integer  "num_valid_votes"
    t.integer  "logic_check_fail"
    t.integer  "logic_check_difference"
    t.integer  "more_ballots_than_votes_flag"
    t.integer  "more_ballots_than_votes"
    t.integer  "more_votes_than_ballots_flag"
    t.integer  "more_votes_than_ballots"
    t.integer  "1 - Tamaz Bibiluri"
    t.integer  "2 - Giorgi Liluashvili"
    t.integer  "3 - Sergo Javakhidze"
    t.integer  "4 - Koba Davitashvili"
    t.integer  "5 - Davit Bakradze"
    t.integer  "6 - Akaki Asatiani"
    t.integer  "7 - Nino Chanishvili"
    t.integer  "8 - Teimuraz Bobokhidze"
    t.integer  "9 - Shalva Natelashvili"
    t.integer  "10 - Giorgi Targamadze"
    t.integer  "11 - Levan Chachua"
    t.integer  "12 - Nestan Kirtadze"
    t.integer  "13 - Giorgi Chikhladze"
    t.integer  "14 - Nino Burjanadze"
    t.integer  "15 - Zurab Kharatishvili"
    t.integer  "16 - Mikheil Saluashvili"
    t.integer  "17 - Kartlos Gharibashvili"
    t.integer  "18 - Mamuka Chokhonelidze"
    t.integer  "19 - Avtandil Margiani"
    t.integer  "20 - Nugzar Avaliani"
    t.integer  "21 - Mamuka Melikishvili"
    t.integer  "22 - Teimuraz Mzhavia"
    t.integer  "41 - Giorgi Margvelashvili"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_overriden",                 :default => false
  end

  add_index "president2013s", ["district_id"], :name => "index_president2013s_on_district_id"
  add_index "president2013s", ["is_overriden"], :name => "index_president2013s_on_is_overriden"
  add_index "president2013s", ["precinct_id"], :name => "index_president2013s_on_precinct_id"
  add_index "president2013s", ["region"], :name => "index_president2013s_on_region"

  create_table "president2013s_precinct_count", :force => true do |t|
    t.string   "region"
    t.integer  "district_id"
    t.integer  "num_precincts"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "president2013s_precinct_count", ["district_id"], :name => "index_president2013s_precinct_count_on_district_id"
  add_index "president2013s_precinct_count", ["region"], :name => "index_president2013s_precinct_count_on_region"

  create_table "region_district_names", :force => true do |t|
    t.string   "region"
    t.integer  "district_id"
    t.string   "district_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "region_district_names", ["district_id"], :name => "index_region_district_names_on_district_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.integer  "role",                   :default => 0,  :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "trained"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
