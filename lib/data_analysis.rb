# methods to work with the data analysis table/views
# - create, delete, run, download, etc
module DataAnalysis
  require 'csv'

  @@vpm_limit = 2

  # use this header text in the csv view
  @@common_headers = [
    'shape',
    'common_id',
    'common_name',
    'Total Voter Turnout (#)',
    'Total Voter Turnout (%)',
    'Number of Precincts with Invalid Ballots from 0-1%',
    'Number of Precincts with Invalid Ballots from 1-3%',
    'Number of Precincts with Invalid Ballots from 3-5%',
    'Number of Precincts with Invalid Ballots > 5%',
    'Invalid Ballots (%)',
    'Precincts with Validation Errors (#)',
    'Precincts with Validation Errors (%)',
    'Average Number of Validation Errors',
    'Number of Validation Errors',
    'Precincts with More Ballots Than Votes (#)',
    'Precincts with More Ballots Than Votes (%)',
    'More Ballots Than Votes (Average)',
    'More Ballots Than Votes (#)','Precincts with More Votes than Ballots (#)',
    'Precincts with More Votes than Ballots (%)',
    'More Votes than Ballots (Average)',
    'More Votes than Ballots (#)','Average votes per minute (08:00-12:00)',
    'Average votes per minute (12:00-17:00)',
    'Average votes per minute (17:00-20:00)',
    "Number of Precincts with votes per minute > #{@@vpm_limit} (08:00-12:00)",
    "Number of Precincts with votes per minute > #{@@vpm_limit} (12:00-17:00)",
    "Number of Precincts with votes per minute > #{@@vpm_limit} (17:00-20:00)",
    "Number of Precincts with votes per minute > #{@@vpm_limit}",
    'Precincts Reported (#)',
    'Precincts Reported (%)'
  ]

  @@shapes = {
    country: 'country',
    region: 'region',
    district: 'district',
    precinct: 'precinct',
    tbilisi_district: 'tbilisi district',
    tbilisi_precinct: 'tbilisi precinct',
    major_district: 'major district',
    major_precinct: 'major precinct',
    major_tbilisi_district: 'major tbilisi district',
    major_tbilisi_precinct: 'major tbilisi precinct'
  }

  @@client = ActiveRecord::Base.connection



  ################################################

  # process an election
  def create_analysis_tables_and_views
    puts "===================="
    puts "creating analysis tables and views for #{self.name}"
    puts "===================="

    run_analysis_tables_and_views

    puts "> done"
    puts "===================="
  end

  ################################################

  # process an election
  def delete_analysis_tables_and_views
    puts "===================="
    puts "deleting analysis tables and views for #{self.name}"
    puts "===================="

    run_analysis_tables_and_views(true)

    puts "> done"
    puts "===================="
  end

  def load_analysis_precinct_counts
    puts "===================="
    puts "load precinct counts table for #{self.name}"
    puts "===================="

    sql = "insert into `#{self.analysis_table_name} - precinct count`
            select region, district_id, "
    if self.is_local_majoritarian
      sql << "major_district_id, "
    end
    sql << "count(*) as num_precints
            from `district_precincts`
            where election_id = #{self.id}
            group by region, district_id"
    if self.is_local_majoritarian
      sql << ", major_district_id"
    end

    @@client.execute(sql)

    puts "> done"
    puts "===================="
  end

  # get all of the data in the raw table and format for csv download
  def download_raw_data
    sql = "select * from `#{self.analysis_table_name} - raw` order by district_id, precinct_id"
    results = @@client.exec_query(sql)

    if results.present?
      csv_data = CSV.generate(:col_sep=>',') do |csv|
        # add header
        csv << results.columns

        # data
        # - each row is a hash so just need to get values
        results.each do |row|
          csv << row.values
        end
      end
    end

    return csv_data
  end

  ###################################################
  ###################################################
  ###################################################
  ###################################################

  private

  ###################################################

  def run_analysis_tables_and_views(delete_only=false)
    puts "===================="
    puts "running analysis tables and views for #{self.name}; delete only = #{delete_only}"
    puts "===================="

    # get parties formatted as hash
    parties = Party.hash_for_analysis(self.id)

    # if there are no parties, we cannot continue
    if parties.empty?
      puts "!!!!!!!!!!!!!!!!!!!!!!"
      puts "WARNING - ANALYSIS TABLES/VIEWS NOT CREATED BECAUSE PARTIES COULD NOT BE FOUND"
      puts "!!!!!!!!!!!!!!!!!!!!!!"
      return
    end

    # run the table
    puts " - raw table"
    run_table(parties, delete_only)

    # run precinct counts
    run_precinct_counts(delete_only)

    # run invalid ballots views
    puts " - invalid ballots"
    run_invalid_ballots(delete_only)

    # run vpm views
    puts " - vpm"
    run_vpm(delete_only)

    # run country view
    puts " - country"
    run_country(parties, delete_only)

    # run regions view
    puts " - region"
    run_regions(parties, delete_only)

    # run districts view
    puts " - district"
    run_districts(parties, delete_only)

    # run precincts view
    puts " - precinct"
    run_precincts(parties, delete_only)

    # run tbilisi districts view
    puts " - tbilisi district"
    run_tbilisi_districts(parties, delete_only)

    # run tbilisi precincts view
    puts " - tbilisi precinct"
    run_tbilisi_precincts(parties, delete_only)

    # run major districts view
    if self.is_local_majoritarian || delete_only
      puts " - major district"
      run_major_districts(parties, delete_only)

      puts " - major tbilisi district"
      run_major_tbilisi_districts(parties, delete_only)
    end

    # run csv view
    puts " - csv"
    run_csv(parties, delete_only)

    puts "> done"
    puts "===================="
  end

  ################################################

  # run the table
  def run_table(parties, delete_only=false)
    table_name = "#{self.analysis_table_name} - raw"
    @@client.execute("drop table if exists `#{table_name}`")
    if !delete_only
      sql = "  CREATE TABLE `#{table_name}` (
        `region` VARCHAR(255) NULL DEFAULT NULL,
        `district_id` INT(11) NULL DEFAULT NULL,
        `district_name` VARCHAR(255) NULL DEFAULT NULL, "

      if self.is_local_majoritarian
        sql << "`major_district_id` INT(11) NULL DEFAULT NULL, "
      end

      sql << "`precinct_id` INT(11) NULL DEFAULT NULL,
        `attached_precinct_id` INT(10) NULL DEFAULT NULL,
        `num_possible_voters` INT(11) NULL DEFAULT NULL,
        `num_special_voters` INT(11) NULL DEFAULT NULL,
        `num_at_12` INT(11) NULL DEFAULT NULL,
        `num_at_17` INT(11) NULL DEFAULT NULL,
        `num_votes` INT(11) NULL DEFAULT NULL,
        `num_ballots` INT(11) NULL DEFAULT NULL,
        `num_invalid_votes` INT(11) NULL DEFAULT NULL,
        `num_valid_votes` INT(11) NULL DEFAULT NULL,
        `logic_check_fail` INT(11) NULL DEFAULT NULL,
        `logic_check_difference` INT(11) NULL DEFAULT NULL,
        `more_ballots_than_votes_flag` INT(11) NULL DEFAULT NULL,
        `more_ballots_than_votes` INT(11) NULL DEFAULT NULL,
        `more_votes_than_ballots_flag` INT(11) NULL DEFAULT NULL,
        `more_votes_than_ballots` INT(11) NULL DEFAULT NULL,"
      party_sql = []
      parties.each do |party|
        party_sql << "`#{party[:id]} - #{party[:name]}` INT(11) NULL DEFAULT NULL"
      end
      sql << party_sql.join(', ')
      sql << ")
      COLLATE='utf8_general_ci'
      ENGINE=MyISAM;"
      @@client.execute(sql)
    end
  end

  ################################################

  # run invalid ballots views
  def run_invalid_ballots(delete_only=false)
    ranges = [
      [0,1],
      [1,3],
      [3,5],
      [5]
    ]

    ranges.each do |range|
      view_name = "#{self.analysis_table_name} - invalid ballots "
      if range.length == 1
        view_name << ">#{range.first}"
      elsif range.length == 2
        view_name << "#{range.first}-#{range.last}"
      end

      @@client.execute("drop view if exists `#{view_name}`")
      if !delete_only
        sql = "create view `#{view_name}` as
          select region, district_id, precinct_id, "
        if self.is_local_majoritarian
          sql << "major_district_id, "
        end
        sql << "count(0) AS `num_invalid_ballots`
          from `#{self.analysis_table_name} - raw`
          where (((100 * (num_invalid_votes / num_votes)) >= #{range.first})"
        if range.length == 2
          sql << " and ((100 * (num_invalid_votes / num_votes)) < #{range.last})"
        end
        sql << ") group by region, district_id, "
        if self.is_local_majoritarian
          sql << "major_district_id, "
        end
        sql << "precinct_id"

        @@client.execute(sql)
      end
    end
  end

  ################################################

  # run vpm views
  def run_vpm(delete_only=false)
    ranges = [
      [8,12],
      [12,17],
      [17,20]
    ]

    ranges.each_with_index do |range, index|
      view_name = "#{self.analysis_table_name} - vpm #{range.first}-#{range.last}>#{@@vpm_limit}"
      mins = (range.last - range.first) * 60
      @@client.execute("drop view if exists `#{view_name}`")
      if !delete_only
        sql = "create view `#{view_name}` as
                select region, district_id, "
        if self.is_local_majoritarian
          sql << "major_district_id, "
        end
        sql << "precinct_id, count(0) AS `vpm > #{@@vpm_limit}`
                from `#{self.analysis_table_name} - raw`"
        if index == 0
          sql << " where ((num_at_#{range.last} / #{mins}) > #{@@vpm_limit})"
        else
          if index == ranges.length-1
            sql << " where (((num_votes - num_at_#{range.first}) / #{mins}) > #{@@vpm_limit})"
          else
            sql << " where (((num_at_#{range.last} - num_at_#{range.first}) / #{mins}) > #{@@vpm_limit})"
          end
        end

        sql << " group by region, district_id, "
        if self.is_local_majoritarian
          sql << "major_district_id, "
        end
        sql << "precinct_id"

        @@client.execute(sql)
      end
    end
  end

  ################################################

  # run country view
  def run_country(parties, delete_only=false)
    view_name = "#{self.analysis_table_name} - #{@@shapes[:country]}"
    @@client.execute("drop view if exists `#{view_name}`")
    if !delete_only
      sql = "create view `#{view_name}` as
            select sum(`raw`.`num_possible_voters`) AS `possible voters`,
            sum(`raw`.`num_votes`) AS `total ballots cast`,
            sum(`raw`.`num_valid_votes`) AS `total valid ballots cast`,
            ifnull(sum(`invalid_ballots_01`.`num_invalid_ballots`),
            0) AS `num invalid ballots from 0-1%`,
            ifnull(sum(`invalid_ballots_13`.`num_invalid_ballots`),
            0) AS `num invalid ballots from 1-3%`,
            ifnull(sum(`invalid_ballots_35`.`num_invalid_ballots`),
            0) AS `num invalid ballots from 3-5%`,
            ifnull(sum(`invalid_ballots_>5`.`num_invalid_ballots`),
            0) AS `num invalid ballots >5%`,
            (100 * (sum(`raw`.`num_valid_votes`) / sum(`raw`.`num_possible_voters`))) AS `percent voters voting`,
            sum(`raw`.`logic_check_fail`) AS `num precincts logic fail`,
            (100 * (sum(`raw`.`logic_check_fail`) / count(0))) AS `percent precincts logic fail`,
            (sum(`raw`.`logic_check_difference`) / sum(`raw`.`logic_check_fail`)) AS `avg precinct logic fail difference`,
            sum(`raw`.`more_ballots_than_votes_flag`) AS `num precincts more ballots than votes`,
            (100 * (sum(`raw`.`more_ballots_than_votes_flag`) / count(0))) AS `percent precincts more ballots than votes`,
            (sum(`raw`.`more_ballots_than_votes`) / sum(`raw`.`more_ballots_than_votes_flag`)) AS `avg precinct difference more ballots than votes`,
            sum(`raw`.`more_votes_than_ballots_flag`) AS `num precincts more votes than ballots`,
            (100 * (sum(`raw`.`more_votes_than_ballots_flag`) / count(0))) AS `percent precincts more votes than ballots`,
            (sum(`raw`.`more_votes_than_ballots`) / sum(`raw`.`more_votes_than_ballots_flag`)) AS `avg precinct difference more votes than ballots`,
            sum(`raw`.`num_at_12`) AS `votes 8-12`,
            sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) AS `votes 12-17`,
            sum((`raw`.`num_votes` - `raw`.`num_at_17`)) AS `votes 17-20`,
            (sum(`raw`.`num_at_12`) / count(0)) AS `avg votes/precinct 8-12`,
            (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / count(0)) AS `avg votes/precinct 12-17`,
            (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / count(0)) AS `avg votes/precinct 17-20`,
            (sum(`raw`.`num_at_12`) / 240) AS `vpm 8-12`,
            (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) AS `vpm 12-17`,
            (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 300) AS `vpm 17-20`,
            ((sum(`raw`.`num_at_12`) / 240) / count(0)) AS `avg vpm/precinct 8-12`,
            ((sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) / count(0)) AS `avg vpm/precinct 12-17`,
            ((sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 200) / count(0)) AS `avg vpm/precinct 17-20`,
            ifnull(sum(`vpm1`.`vpm > #{@@vpm_limit}`),
            0) AS `num precincts vpm 8-12 > #{@@vpm_limit}`,
            ifnull(sum(`vpm2`.`vpm > #{@@vpm_limit}`),
            0) AS `num precincts vpm 12-17 > #{@@vpm_limit}`,
            ifnull(sum(`vpm3`.`vpm > #{@@vpm_limit}`),
            0) AS `num precincts vpm 17-20 > #{@@vpm_limit}`,
            ((ifnull(sum(`vpm1`.`vpm > #{@@vpm_limit}`),
            0) + ifnull(sum(`vpm2`.`vpm > #{@@vpm_limit}`),
            0)) + ifnull(sum(`vpm3`.`vpm > #{@@vpm_limit}`),
            0)) AS `num precincts vpm > #{@@vpm_limit}`,
            `precinct_count`.`num_precincts` AS `num_precincts_possible`,
            count(`raw`.`precinct_id`) AS `num_precincts_reported_number`,
            ((100 * count(`raw`.`precinct_id`)) / `precinct_count`.`num_precincts`) AS `num_precincts_reported_percent`,
            "
      party_sql = []
      parties.each do |party|
        party_name = "#{party[:id]} - #{party[:name]}"
        party_sql << "sum(`raw`.`#{party_name}`) AS `#{party_name} count`,
                     (100 * (sum(`raw`.`#{party_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{party_name}`"
      end
      sql << party_sql.join(', ')

      sql << " from ((((((((`#{self.analysis_table_name} - raw` `raw`
              join `#{self.analysis_table_name} - precinct count by #{@@shapes[:country]}` `precinct_count`
              left join `#{self.analysis_table_name} - vpm 8-12>#{@@vpm_limit}` `vpm1` on(((`raw`.`region` = `vpm1`.`region`) and (`raw`.`district_id` = `vpm1`.`district_id`) and (`raw`.`precinct_id` = `vpm1`.`precinct_id`))))
              left join `#{self.analysis_table_name} - vpm 12-17>#{@@vpm_limit}` `vpm2` on(((`raw`.`region` = `vpm2`.`region`) and (`raw`.`district_id` = `vpm2`.`district_id`) and (`raw`.`precinct_id` = `vpm2`.`precinct_id`))))
              left join `#{self.analysis_table_name} - vpm 17-20>#{@@vpm_limit}` `vpm3` on(((`raw`.`region` = convert(`vpm3`.`region` using utf8)) and (`raw`.`district_id` = `vpm3`.`district_id`) and (`raw`.`precinct_id` = `vpm3`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 0-1` `invalid_ballots_01` on(((`raw`.`region` = `invalid_ballots_01`.`region`) and (`raw`.`district_id` = `invalid_ballots_01`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_01`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 1-3` `invalid_ballots_13` on(((`raw`.`region` = `invalid_ballots_13`.`region`) and (`raw`.`district_id` = `invalid_ballots_13`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_13`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 3-5` `invalid_ballots_35` on(((`raw`.`region` = `invalid_ballots_35`.`region`) and (`raw`.`district_id` = `invalid_ballots_35`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_35`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots >5` `invalid_ballots_>5` on(((`raw`.`region` = `invalid_ballots_>5`.`region`) and (`raw`.`district_id` = `invalid_ballots_>5`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_>5`.`precinct_id`)))))
              "

      @@client.execute(sql)
    end
  end

  ################################################

  # run regions view
  def run_regions(parties, delete_only=false)
    view_name = "#{self.analysis_table_name} - #{@@shapes[:region]}"
    @@client.execute("drop view if exists `#{view_name}`")
    if !delete_only
      sql = "create view `#{view_name}` as
            select `raw`.`region` AS `region`,
            sum(`raw`.`num_possible_voters`) AS `possible voters`,
            sum(`raw`.`num_votes`) AS `total ballots cast`,
            sum(`raw`.`num_valid_votes`) AS `total valid ballots cast`,
            ifnull(sum(`invalid_ballots_01`.`num_invalid_ballots`),
            0) AS `num invalid ballots from 0-1%`,
            ifnull(sum(`invalid_ballots_13`.`num_invalid_ballots`),
            0) AS `num invalid ballots from 1-3%`,
            ifnull(sum(`invalid_ballots_35`.`num_invalid_ballots`),
            0) AS `num invalid ballots from 3-5%`,
            ifnull(sum(`invalid_ballots_>5`.`num_invalid_ballots`),
            0) AS `num invalid ballots >5%`,
            (100 * (sum(`raw`.`num_valid_votes`) / sum(`raw`.`num_possible_voters`))) AS `percent voters voting`,
            sum(`raw`.`logic_check_fail`) AS `num precincts logic fail`,
            (100 * (sum(`raw`.`logic_check_fail`) / count(0))) AS `percent precincts logic fail`,
            (sum(`raw`.`logic_check_difference`) / sum(`raw`.`logic_check_fail`)) AS `avg precinct logic fail difference`,
            sum(`raw`.`more_ballots_than_votes_flag`) AS `num precincts more ballots than votes`,
            (100 * (sum(`raw`.`more_ballots_than_votes_flag`) / count(0))) AS `percent precincts more ballots than votes`,
            (sum(`raw`.`more_ballots_than_votes`) / sum(`raw`.`more_ballots_than_votes_flag`)) AS `avg precinct difference more ballots than votes`,
            sum(`raw`.`more_votes_than_ballots_flag`) AS `num precincts more votes than ballots`,
            (100 * (sum(`raw`.`more_votes_than_ballots_flag`) / count(0))) AS `percent precincts more votes than ballots`,
            (sum(`raw`.`more_votes_than_ballots`) / sum(`raw`.`more_votes_than_ballots_flag`)) AS `avg precinct difference more votes than ballots`,
            sum(`raw`.`num_at_12`) AS `votes 8-12`,
            sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) AS `votes 12-17`,
            sum((`raw`.`num_votes` - `raw`.`num_at_17`)) AS `votes 17-20`,
            (sum(`raw`.`num_at_12`) / count(0)) AS `avg votes/precinct 8-12`,
            (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / count(0)) AS `avg votes/precinct 12-17`,
            (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / count(0)) AS `avg votes/precinct 17-20`,
            (sum(`raw`.`num_at_12`) / 240) AS `vpm 8-12`,
            (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) AS `vpm 12-17`,
            (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 300) AS `vpm 17-20`,
            ((sum(`raw`.`num_at_12`) / 240) / count(0)) AS `avg vpm/precinct 8-12`,
            ((sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) / count(0)) AS `avg vpm/precinct 12-17`,
            ((sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 200) / count(0)) AS `avg vpm/precinct 17-20`,
            ifnull(sum(`vpm1`.`vpm > #{@@vpm_limit}`),
            0) AS `num precincts vpm 8-12 > #{@@vpm_limit}`,
            ifnull(sum(`vpm2`.`vpm > #{@@vpm_limit}`),
            0) AS `num precincts vpm 12-17 > #{@@vpm_limit}`,
            ifnull(sum(`vpm3`.`vpm > #{@@vpm_limit}`),
            0) AS `num precincts vpm 17-20 > #{@@vpm_limit}`,
            ((ifnull(sum(`vpm1`.`vpm > #{@@vpm_limit}`),
            0) + ifnull(sum(`vpm2`.`vpm > #{@@vpm_limit}`),
            0)) + ifnull(sum(`vpm3`.`vpm > #{@@vpm_limit}`),
            0)) AS `num precincts vpm > #{@@vpm_limit}`,
            `precinct_count`.`num_precincts` AS `num_precincts_possible`,
            count(`raw`.`precinct_id`) AS `num_precincts_reported_number`,
            ((100 * count(`raw`.`precinct_id`)) / `precinct_count`.`num_precincts`) AS `num_precincts_reported_percent`,
            "
      party_sql = []
      parties.each do |party|
        party_name = "#{party[:id]} - #{party[:name]}"
        party_sql << "sum(`raw`.`#{party_name}`) AS `#{party_name} count`,
                     (100 * (sum(`raw`.`#{party_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{party_name}`"
      end
      sql << party_sql.join(', ')

      sql << " from ((((((((`#{self.analysis_table_name} - raw` `raw`
              join `#{self.analysis_table_name} - precinct count by region` `precinct_count` on((`raw`.`region` = `precinct_count`.`region`)))
              left join `#{self.analysis_table_name} - vpm 8-12>#{@@vpm_limit}` `vpm1` on(((`raw`.`region` = `vpm1`.`region`) and (`raw`.`district_id` = `vpm1`.`district_id`) and (`raw`.`precinct_id` = `vpm1`.`precinct_id`))))
              left join `#{self.analysis_table_name} - vpm 12-17>#{@@vpm_limit}` `vpm2` on(((`raw`.`region` = `vpm2`.`region`) and (`raw`.`district_id` = `vpm2`.`district_id`) and (`raw`.`precinct_id` = `vpm2`.`precinct_id`))))
              left join `#{self.analysis_table_name} - vpm 17-20>#{@@vpm_limit}` `vpm3` on(((`raw`.`region` = convert(`vpm3`.`region` using utf8)) and (`raw`.`district_id` = `vpm3`.`district_id`) and (`raw`.`precinct_id` = `vpm3`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 0-1` `invalid_ballots_01` on(((`raw`.`region` = `invalid_ballots_01`.`region`) and (`raw`.`district_id` = `invalid_ballots_01`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_01`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 1-3` `invalid_ballots_13` on(((`raw`.`region` = `invalid_ballots_13`.`region`) and (`raw`.`district_id` = `invalid_ballots_13`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_13`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 3-5` `invalid_ballots_35` on(((`raw`.`region` = `invalid_ballots_35`.`region`) and (`raw`.`district_id` = `invalid_ballots_35`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_35`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots >5` `invalid_ballots_>5` on(((`raw`.`region` = `invalid_ballots_>5`.`region`) and (`raw`.`district_id` = `invalid_ballots_>5`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_>5`.`precinct_id`))))
              group by `raw`.`region`"

      @@client.execute(sql)
    end
  end

  ################################################

  # run districts view
  # - all of tbilisi is considered as a district so the data for all districts in tbilisi have to be aggregated
  # - this happens by getting all districts not in tbilisi and then adding tbilisi using a union
  def run_districts(parties, delete_only=false)
    view_name = "#{self.analysis_table_name} - #{@@shapes[:district]}"
    @@client.execute("drop view if exists `#{view_name}`")
    if !delete_only
      sql = "create view `#{view_name}` as
              select `raw`.`region` AS `region`,
              `raw`.`district_id` AS `district_id`,
              `raw`.`district_name` AS `district_Name`,
              sum(`raw`.`num_possible_voters`) AS `possible voters`,
              sum(`raw`.`num_votes`) AS `total ballots cast`,
              sum(`raw`.`num_valid_votes`) AS `total valid ballots cast`,
              ifnull(sum(`invalid_ballots_01`.`num_invalid_ballots`),
              0) AS `num invalid ballots from 0-1%`,
              ifnull(sum(`invalid_ballots_13`.`num_invalid_ballots`),
              0) AS `num invalid ballots from 1-3%`,
              ifnull(sum(`invalid_ballots_35`.`num_invalid_ballots`),
              0) AS `num invalid ballots from 3-5%`,
              ifnull(sum(`invalid_ballots_>5`.`num_invalid_ballots`),
              0) AS `num invalid ballots >5%`,
              (100 * (sum(`raw`.`num_valid_votes`) / sum(`raw`.`num_possible_voters`))) AS `percent voters voting`,
              sum(`raw`.`logic_check_fail`) AS `num precincts logic fail`,
              (100 * (sum(`raw`.`logic_check_fail`) / count(0))) AS `percent precincts logic fail`,
              (sum(`raw`.`logic_check_difference`) / sum(`raw`.`logic_check_fail`)) AS `avg precinct logic fail difference`,
              sum(`raw`.`more_ballots_than_votes_flag`) AS `num precincts more ballots than votes`,
              (100 * (sum(`raw`.`more_ballots_than_votes_flag`) / count(0))) AS `percent precincts more ballots than votes`,
              (sum(`raw`.`more_ballots_than_votes`) / sum(`raw`.`more_ballots_than_votes_flag`)) AS `avg precinct difference more ballots than votes`,
              sum(`raw`.`more_votes_than_ballots_flag`) AS `num precincts more votes than ballots`,
              (100 * (sum(`raw`.`more_votes_than_ballots_flag`) / count(0))) AS `percent precincts more votes than ballots`,
              (sum(`raw`.`more_votes_than_ballots`) / sum(`raw`.`more_votes_than_ballots_flag`)) AS `avg precinct difference more votes than ballots`,
              sum(`raw`.`num_at_12`) AS `votes 8-12`,
              sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) AS `votes 12-17`,
              sum((`raw`.`num_votes` - `raw`.`num_at_17`)) AS `votes 17-20`,
              (sum(`raw`.`num_at_12`) / count(0)) AS `avg votes/precinct 8-12`,
              (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / count(0)) AS `avg votes/precinct 12-17`,
              (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / count(0)) AS `avg votes/precinct 17-20`,
              (sum(`raw`.`num_at_12`) / 240) AS `vpm 8-12`,
              (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) AS `vpm 12-17`,
              (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 300) AS `vpm 17-20`,
              ((sum(`raw`.`num_at_12`) / 240) / count(0)) AS `avg vpm/precinct 8-12`,
              ((sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) / count(0)) AS `avg vpm/precinct 12-17`,
              ((sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 200) / count(0)) AS `avg vpm/precinct 17-20`,
              ifnull(sum(`vpm1`.`vpm > #{@@vpm_limit}`),
              0) AS `num precincts vpm 8-12 > #{@@vpm_limit}`,
              ifnull(sum(`vpm2`.`vpm > #{@@vpm_limit}`),
              0) AS `num precincts vpm 12-17 > #{@@vpm_limit}`,
              ifnull(sum(`vpm3`.`vpm > #{@@vpm_limit}`),
              0) AS `num precincts vpm 17-20 > #{@@vpm_limit}`,
              ((ifnull(sum(`vpm1`.`vpm > #{@@vpm_limit}`),
              0) + ifnull(sum(`vpm2`.`vpm > #{@@vpm_limit}`),
              0)) + ifnull(sum(`vpm3`.`vpm > #{@@vpm_limit}`),
              0)) AS `num precincts vpm > #{@@vpm_limit}`,
              `precinct_count`.`num_precincts` AS `num_precincts_possible`,
              count(`raw`.`precinct_id`) AS `num_precincts_reported_number`,
              ((100 * count(`raw`.`precinct_id`)) / `precinct_count`.`num_precincts`) AS `num_precincts_reported_percent`,
            "
      party_sql = []
      parties.each do |party|
        party_name = "#{party[:id]} - #{party[:name]}"
        party_sql << "sum(`raw`.`#{party_name}`) AS `#{party_name} count`,
                     (100 * (sum(`raw`.`#{party_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{party_name}`"
      end
      sql << party_sql.join(', ')

      sql << " from ((((((((`#{self.analysis_table_name} - raw` `raw`
              join `#{self.analysis_table_name} - precinct count by district` `precinct_count` on((`raw`.`district_id` = `precinct_count`.`district_id`)))
              left join `#{self.analysis_table_name} - vpm 8-12>#{@@vpm_limit}` `vpm1` on(((`raw`.`region` = `vpm1`.`region`) and (`raw`.`district_id` = `vpm1`.`district_id`) and (`raw`.`precinct_id` = `vpm1`.`precinct_id`))))
              left join `#{self.analysis_table_name} - vpm 12-17>#{@@vpm_limit}` `vpm2` on(((`raw`.`region` = `vpm2`.`region`) and (`raw`.`district_id` = `vpm2`.`district_id`) and (`raw`.`precinct_id` = `vpm2`.`precinct_id`))))
              left join `#{self.analysis_table_name} - vpm 17-20>#{@@vpm_limit}` `vpm3` on(((`raw`.`region` = convert(`vpm3`.`region` using utf8)) and (`raw`.`district_id` = `vpm3`.`district_id`) and (`raw`.`precinct_id` = `vpm3`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 0-1` `invalid_ballots_01` on(((`raw`.`region` = `invalid_ballots_01`.`region`) and (`raw`.`district_id` = `invalid_ballots_01`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_01`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 1-3` `invalid_ballots_13` on(((`raw`.`region` = `invalid_ballots_13`.`region`) and (`raw`.`district_id` = `invalid_ballots_13`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_13`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 3-5` `invalid_ballots_35` on(((`raw`.`region` = `invalid_ballots_35`.`region`) and (`raw`.`district_id` = `invalid_ballots_35`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_35`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots >5` `invalid_ballots_>5` on(((`raw`.`region` = `invalid_ballots_>5`.`region`) and (`raw`.`district_id` = `invalid_ballots_>5`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_>5`.`precinct_id`))))
              where (`raw`.`district_id` not between 1 and 10)
              group by `raw`.`region`, `raw`.`district_name`, `raw`.`district_id`"

      sql << " union "

      sql << "select `raw`.`region` AS `region`,
              999 AS `district_id`,
              `raw`.`region` AS `district_name`,
              sum(`raw`.`num_possible_voters`) AS `possible voters`,
              sum(`raw`.`num_votes`) AS `total ballots cast`,
              sum(`raw`.`num_valid_votes`) AS `total valid ballots cast`,
              ifnull(sum(`invalid_ballots_01`.`num_invalid_ballots`),
              0) AS `num invalid ballots from 0-1%`,
              ifnull(sum(`invalid_ballots_13`.`num_invalid_ballots`),
              0) AS `num invalid ballots from 1-3%`,
              ifnull(sum(`invalid_ballots_35`.`num_invalid_ballots`),
              0) AS `num invalid ballots from 3-5%`,
              ifnull(sum(`invalid_ballots_>5`.`num_invalid_ballots`),
              0) AS `num invalid ballots >5%`,
              (100 * (sum(`raw`.`num_valid_votes`) / sum(`raw`.`num_possible_voters`))) AS `percent voters voting`,
              sum(`raw`.`logic_check_fail`) AS `num precincts logic fail`,
              (100 * (sum(`raw`.`logic_check_fail`) / count(0))) AS `percent precincts logic fail`,
              (sum(`raw`.`logic_check_difference`) / sum(`raw`.`logic_check_fail`)) AS `avg precinct logic fail difference`,
              sum(`raw`.`more_ballots_than_votes_flag`) AS `num precincts more ballots than votes`,
              (100 * (sum(`raw`.`more_ballots_than_votes_flag`) / count(0))) AS `percent precincts more ballots than votes`,
              (sum(`raw`.`more_ballots_than_votes`) / sum(`raw`.`more_ballots_than_votes_flag`)) AS `avg precinct difference more ballots than votes`,
              sum(`raw`.`more_votes_than_ballots_flag`) AS `num precincts more votes than ballots`,
              (100 * (sum(`raw`.`more_votes_than_ballots_flag`) / count(0))) AS `percent precincts more votes than ballots`,
              (sum(`raw`.`more_votes_than_ballots`) / sum(`raw`.`more_votes_than_ballots_flag`)) AS `avg precinct difference more votes than ballots`,
              sum(`raw`.`num_at_12`) AS `votes 8-12`,
              sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) AS `votes 12-17`,
              sum((`raw`.`num_votes` - `raw`.`num_at_17`)) AS `votes 17-20`,
              (sum(`raw`.`num_at_12`) / count(0)) AS `avg votes/precinct 8-12`,
              (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / count(0)) AS `avg votes/precinct 12-17`,
              (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / count(0)) AS `avg votes/precinct 17-20`,
              (sum(`raw`.`num_at_12`) / 240) AS `vpm 8-12`,
              (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) AS `vpm 12-17`,
              (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 300) AS `vpm 17-20`,
              ((sum(`raw`.`num_at_12`) / 240) / count(0)) AS `avg vpm/precinct 8-12`,
              ((sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) / count(0)) AS `avg vpm/precinct 12-17`,
              ((sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 200) / count(0)) AS `avg vpm/precinct 17-20`,
              ifnull(sum(`vpm1`.`vpm > #{@@vpm_limit}`),
              0) AS `num precincts vpm 8-12 > #{@@vpm_limit}`,
              ifnull(sum(`vpm2`.`vpm > #{@@vpm_limit}`),
              0) AS `num precincts vpm 12-17 > #{@@vpm_limit}`,
              ifnull(sum(`vpm3`.`vpm > #{@@vpm_limit}`),
              0) AS `num precincts vpm 17-20 > #{@@vpm_limit}`,
              ((ifnull(sum(`vpm1`.`vpm > #{@@vpm_limit}`),
              0) + ifnull(sum(`vpm2`.`vpm > #{@@vpm_limit}`),
              0)) + ifnull(sum(`vpm3`.`vpm > #{@@vpm_limit}`),
              0)) AS `num precincts vpm > #{@@vpm_limit}`,
              `precinct_count`.`num_precincts` AS `num_precincts_possible`,
              count(`raw`.`precinct_id`) AS `num_precincts_reported_number`,
              ((100 * count(`raw`.`precinct_id`)) / `precinct_count`.`num_precincts`) AS `num_precincts_reported_percent`,
            "
      party_sql = []
      parties.each do |party|
        party_name = "#{party[:id]} - #{party[:name]}"
        party_sql << "sum(`raw`.`#{party_name}`) AS `#{party_name} count`,
                     (100 * (sum(`raw`.`#{party_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{party_name}`"
      end
      sql << party_sql.join(', ')

      sql << " from ((((((((`#{self.analysis_table_name} - raw` `raw`
              join `#{self.analysis_table_name} - precinct count by region` `precinct_count` on((`raw`.`region` = `precinct_count`.`region`)))
              left join `#{self.analysis_table_name} - vpm 8-12>#{@@vpm_limit}` `vpm1` on(((`raw`.`region` = `vpm1`.`region`) and (`raw`.`district_id` = `vpm1`.`district_id`) and (`raw`.`precinct_id` = `vpm1`.`precinct_id`))))
              left join `#{self.analysis_table_name} - vpm 12-17>#{@@vpm_limit}` `vpm2` on(((`raw`.`region` = `vpm2`.`region`) and (`raw`.`district_id` = `vpm2`.`district_id`) and (`raw`.`precinct_id` = `vpm2`.`precinct_id`))))
              left join `#{self.analysis_table_name} - vpm 17-20>#{@@vpm_limit}` `vpm3` on(((`raw`.`region` = convert(`vpm3`.`region` using utf8)) and (`raw`.`district_id` = `vpm3`.`district_id`) and (`raw`.`precinct_id` = `vpm3`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 0-1` `invalid_ballots_01` on(((`raw`.`region` = `invalid_ballots_01`.`region`) and (`raw`.`district_id` = `invalid_ballots_01`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_01`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 1-3` `invalid_ballots_13` on(((`raw`.`region` = `invalid_ballots_13`.`region`) and (`raw`.`district_id` = `invalid_ballots_13`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_13`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 3-5` `invalid_ballots_35` on(((`raw`.`region` = `invalid_ballots_35`.`region`) and (`raw`.`district_id` = `invalid_ballots_35`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_35`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots >5` `invalid_ballots_>5` on(((`raw`.`region` = `invalid_ballots_>5`.`region`) and (`raw`.`district_id` = `invalid_ballots_>5`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_>5`.`precinct_id`))))
              where (`raw`.`district_id` between 1 and 10)
              group by `raw`.`region`"

      @@client.execute(sql)
    end
  end

  ################################################

  # run precincts view
  def run_precincts(parties, delete_only=false)
    major_name = self.is_local_majoritarian == true ? 'major_' : ''
    shape = @@shapes[:"#{major_name}precinct"]
    view_name = "#{self.analysis_table_name} - #{shape}"
    @@client.execute("drop view if exists `#{view_name}`")
    if !delete_only
      sql = "create view `#{view_name}` as
            select `raw`.`region` AS `region`,
            `raw`.`district_id` AS `district_id`,
            `raw`.`district_name` AS `district_Name`,"
      if self.is_local_majoritarian
        sql << "`raw`.`major_district_id` AS `major_district_id`,
                  concat(cast(`raw`.`district_id` as char charset utf8),
                  '-',
                  cast(`raw`.`major_district_id` as char charset utf8)) AS `major_district_name`,"
      end
      sql << "`raw`.`precinct_id` AS `precinct_id`,
            concat(cast(`raw`.`district_id` as char charset utf8),
            '-',
            cast(`raw`.`precinct_id` as char charset utf8)) AS `precinct_name`,
            `raw`.`num_possible_voters` AS `possible voters`,
            `raw`.`num_votes` AS `total ballots cast`,
            `raw`.`num_valid_votes` AS `total valid ballots cast`,
            (100 * (`raw`.`num_invalid_votes` / `raw`.`num_votes`)) AS `percent invalid ballots`,
            (100 * (`raw`.`num_valid_votes` / `raw`.`num_possible_voters`)) AS `percent voters voting`,
            `raw`.`logic_check_fail` AS `logic_check_fail`,
            `raw`.`logic_check_difference` AS `logic_check_difference`,
            `raw`.`more_ballots_than_votes_flag` as `more_ballots_than_votes_flag`,
            `raw`.`more_ballots_than_votes` as `more_ballots_than_votes`,
            `raw`.`more_votes_than_ballots_flag` as `more_votes_than_ballots_flag`,
            `raw`.`more_votes_than_ballots` as `more_votes_than_ballots`,
            `raw`.`num_at_12` AS `votes 8-12`,
            (`raw`.`num_at_17` - `raw`.`num_at_12`) AS `votes 12-17`,
            (`raw`.`num_votes` - `raw`.`num_at_17`) AS `votes 17-20`,
            (`raw`.`num_at_12` / 240) AS `vpm 8-12`,
            ((`raw`.`num_at_17` - `raw`.`num_at_12`) / 300) AS `vpm 12-17`,
            ((`raw`.`num_votes` - `raw`.`num_at_17`) / 180) AS `vpm 17-20`,
            "
      party_sql = []
      parties.each do |party|
        party_name = "#{party[:id]} - #{party[:name]}"
        party_sql << "`raw`.`#{party_name}` AS `#{party_name} count`,
                     (100 * (`raw`.`#{party_name}` / `raw`.`num_valid_votes`)) AS `#{party_name}`"
      end
      sql << party_sql.join(', ')

      sql << "from `#{self.analysis_table_name} - raw` `raw` where (`raw`.`district_id` not between 1 and 10)"

      @@client.execute(sql)
    end
  end

  ################################################

  # run tbilisi districts view
  def run_tbilisi_districts(parties, delete_only=false)
    view_name = "#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}"
    @@client.execute("drop view if exists `#{view_name}`")
    if !delete_only
      sql = "create view `#{view_name}` as
            select `raw`.`region` AS `region`,
            `raw`.`district_id` AS `district_id`,
            `raw`.`district_name` AS `district_Name`,
            sum(`raw`.`num_possible_voters`) AS `possible voters`,
            sum(`raw`.`num_votes`) AS `total ballots cast`,
            sum(`raw`.`num_valid_votes`) AS `total valid ballots cast`,
            ifnull(sum(`invalid_ballots_01`.`num_invalid_ballots`),
            0) AS `num invalid ballots from 0-1%`,
            ifnull(sum(`invalid_ballots_13`.`num_invalid_ballots`),
            0) AS `num invalid ballots from 1-3%`,
            ifnull(sum(`invalid_ballots_35`.`num_invalid_ballots`),
            0) AS `num invalid ballots from 3-5%`,
            ifnull(sum(`invalid_ballots_>5`.`num_invalid_ballots`),
            0) AS `num invalid ballots >5%`,
            (100 * (sum(`raw`.`num_valid_votes`) / sum(`raw`.`num_possible_voters`))) AS `percent voters voting`,
            sum(`raw`.`logic_check_fail`) AS `num precincts logic fail`,
            (100 * (sum(`raw`.`logic_check_fail`) / count(0))) AS `percent precincts logic fail`,
            (sum(`raw`.`logic_check_difference`) / sum(`raw`.`logic_check_fail`)) AS `avg precinct logic fail difference`,
            sum(`raw`.`more_ballots_than_votes_flag`) AS `num precincts more ballots than votes`,
            (100 * (sum(`raw`.`more_ballots_than_votes_flag`) / count(0))) AS `percent precincts more ballots than votes`,
            (sum(`raw`.`more_ballots_than_votes`) / sum(`raw`.`more_ballots_than_votes_flag`)) AS `avg precinct difference more ballots than votes`,
            sum(`raw`.`more_votes_than_ballots_flag`) AS `num precincts more votes than ballots`,
            (100 * (sum(`raw`.`more_votes_than_ballots_flag`) / count(0))) AS `percent precincts more votes than ballots`,
            (sum(`raw`.`more_votes_than_ballots`) / sum(`raw`.`more_votes_than_ballots_flag`)) AS `avg precinct difference more votes than ballots`,
            sum(`raw`.`num_at_12`) AS `votes 8-12`,
            sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) AS `votes 12-17`,
            sum((`raw`.`num_votes` - `raw`.`num_at_17`)) AS `votes 17-20`,
            (sum(`raw`.`num_at_12`) / count(0)) AS `avg votes/precinct 8-12`,
            (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / count(0)) AS `avg votes/precinct 12-17`,
            (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / count(0)) AS `avg votes/precinct 17-20`,
            (sum(`raw`.`num_at_12`) / 240) AS `vpm 8-12`,
            (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) AS `vpm 12-17`,
            (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 300) AS `vpm 17-20`,
            ((sum(`raw`.`num_at_12`) / 240) / count(0)) AS `avg vpm/precinct 8-12`,
            ((sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) / count(0)) AS `avg vpm/precinct 12-17`,
            ((sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 200) / count(0)) AS `avg vpm/precinct 17-20`,
            ifnull(sum(`vpm1`.`vpm > #{@@vpm_limit}`),
            0) AS `num precincts vpm 8-12 > #{@@vpm_limit}`,
            ifnull(sum(`vpm2`.`vpm > #{@@vpm_limit}`),
            0) AS `num precincts vpm 12-17 > #{@@vpm_limit}`,
            ifnull(sum(`vpm3`.`vpm > #{@@vpm_limit}`),
            0) AS `num precincts vpm 17-20 > #{@@vpm_limit}`,
            ((ifnull(sum(`vpm1`.`vpm > #{@@vpm_limit}`),
            0) + ifnull(sum(`vpm2`.`vpm > #{@@vpm_limit}`),
            0)) + ifnull(sum(`vpm3`.`vpm > #{@@vpm_limit}`),
            0)) AS `num precincts vpm > #{@@vpm_limit}`,
            `precinct_count`.`num_precincts` AS `num_precincts_possible`,
            count(`raw`.`precinct_id`) AS `num_precincts_reported_number`,
            ((100 * count(`raw`.`precinct_id`)) / `precinct_count`.`num_precincts`) AS `num_precincts_reported_percent`,
            "
      party_sql = []
      parties.each do |party|
        party_name = "#{party[:id]} - #{party[:name]}"
        party_sql << "sum(`raw`.`#{party_name}`) AS `#{party_name} count`,
                     (100 * (sum(`raw`.`#{party_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{party_name}`"
      end
      sql << party_sql.join(', ')

      sql << " from ((((((((`#{self.analysis_table_name} - raw` `raw`
              join `#{self.analysis_table_name} - precinct count by district` `precinct_count` on((`raw`.`district_id` = `precinct_count`.`district_id`)))
              left join `#{self.analysis_table_name} - vpm 8-12>#{@@vpm_limit}` `vpm1` on(((`raw`.`region` = `vpm1`.`region`) and (`raw`.`district_id` = `vpm1`.`district_id`) and (`raw`.`precinct_id` = `vpm1`.`precinct_id`))))
              left join `#{self.analysis_table_name} - vpm 12-17>#{@@vpm_limit}` `vpm2` on(((`raw`.`region` = `vpm2`.`region`) and (`raw`.`district_id` = `vpm2`.`district_id`) and (`raw`.`precinct_id` = `vpm2`.`precinct_id`))))
              left join `#{self.analysis_table_name} - vpm 17-20>#{@@vpm_limit}` `vpm3` on(((`raw`.`region` = convert(`vpm3`.`region` using utf8)) and (`raw`.`district_id` = `vpm3`.`district_id`) and (`raw`.`precinct_id` = `vpm3`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 0-1` `invalid_ballots_01` on(((`raw`.`region` = `invalid_ballots_01`.`region`) and (`raw`.`district_id` = `invalid_ballots_01`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_01`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 1-3` `invalid_ballots_13` on(((`raw`.`region` = `invalid_ballots_13`.`region`) and (`raw`.`district_id` = `invalid_ballots_13`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_13`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 3-5` `invalid_ballots_35` on(((`raw`.`region` = `invalid_ballots_35`.`region`) and (`raw`.`district_id` = `invalid_ballots_35`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_35`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots >5` `invalid_ballots_>5` on(((`raw`.`region` = `invalid_ballots_>5`.`region`) and (`raw`.`district_id` = `invalid_ballots_>5`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_>5`.`precinct_id`))))
              where (`raw`.`district_id` between 1 and 10)
              group by `raw`.`region`, `raw`.`district_name`, `raw`.`district_id`"

      @@client.execute(sql)
    end
  end

  ################################################

  # run tbilisi precincts view
  # note - precincts and tbilisi precincts are same except for view name and the from clause
  def run_tbilisi_precincts(parties, delete_only=false)
    major_name = self.is_local_majoritarian == true ? 'major_' : ''
    shape = @@shapes[:"#{major_name}tbilisi_precinct"]
    view_name = "#{self.analysis_table_name} - #{shape}"
    @@client.execute("drop view if exists `#{view_name}`")
    if !delete_only
      sql = "create view `#{view_name}` as
            select `raw`.`region` AS `region`,
            `raw`.`district_id` AS `district_id`,
            `raw`.`district_name` AS `district_Name`,"
      if self.is_local_majoritarian
        sql << "`raw`.`major_district_id` AS `major_district_id`,
                  concat(cast(`raw`.`district_id` as char charset utf8),
                  '-',
                  cast(`raw`.`major_district_id` as char charset utf8)) AS `major_district_name`,"
      end
      sql << "`raw`.`precinct_id` AS `precinct_id`,
              concat(cast(`raw`.`district_id` as char charset utf8),
              '-',
              cast(`raw`.`precinct_id` as char charset utf8)) AS `precinct_name`,
              `raw`.`num_possible_voters` AS `possible voters`,
              `raw`.`num_votes` AS `total ballots cast`,
              `raw`.`num_valid_votes` AS `total valid ballots cast`,
              (100 * (`raw`.`num_invalid_votes` / `raw`.`num_votes`)) AS `percent invalid ballots`,
              (100 * (`raw`.`num_valid_votes` / `raw`.`num_possible_voters`)) AS `percent voters voting`,
              `raw`.`logic_check_fail` AS `logic_check_fail`,
              `raw`.`logic_check_difference` AS `logic_check_difference`,
              `raw`.`more_ballots_than_votes_flag` as `more_ballots_than_votes_flag`,
              `raw`.`more_ballots_than_votes` as `more_ballots_than_votes`,
              `raw`.`more_votes_than_ballots_flag` as `more_votes_than_ballots_flag`,
              `raw`.`more_votes_than_ballots` as `more_votes_than_ballots`,
              `raw`.`num_at_12` AS `votes 8-12`,
              (`raw`.`num_at_17` - `raw`.`num_at_12`) AS `votes 12-17`,
              (`raw`.`num_votes` - `raw`.`num_at_17`) AS `votes 17-20`,
              (`raw`.`num_at_12` / 240) AS `vpm 8-12`,
              ((`raw`.`num_at_17` - `raw`.`num_at_12`) / 300) AS `vpm 12-17`,
              ((`raw`.`num_votes` - `raw`.`num_at_17`) / 180) AS `vpm 17-20`,
            "
      party_sql = []
      parties.each do |party|
        party_name = "#{party[:id]} - #{party[:name]}"
        party_sql << "`raw`.`#{party_name}` AS `#{party_name} count`,
                     (100 * (`raw`.`#{party_name}` / `raw`.`num_valid_votes`)) AS `#{party_name}`"
      end
      sql << party_sql.join(', ')

      sql << "from `#{self.analysis_table_name} - raw` `raw` where (`raw`.`district_id` between 1 and 10)"

      @@client.execute(sql)
    end
  end

  ################################################

  # run major district view
  def run_major_districts(parties, delete_only=false)
    view_name = "#{self.analysis_table_name} - #{@@shapes[:major_district]}"
    @@client.execute("drop view if exists `#{view_name}`")
    if !delete_only
      sql = "create view `#{view_name}` as
              select `raw`.`region` AS `region`,
              `raw`.`district_id` AS `district_id`,
              `raw`.`district_name` AS `district_Name`,
              `raw`.`major_district_id` AS `major_district_id`,
              concat(cast(`raw`.`district_id` as char charset utf8),
              '-',
              cast(`raw`.`major_district_id` as char charset utf8)) AS `major_district_name`,
              sum(`raw`.`num_possible_voters`) AS `possible voters`,
              sum(`raw`.`num_votes`) AS `total ballots cast`,
              sum(`raw`.`num_valid_votes`) AS `total valid ballots cast`,
              ifnull(sum(`invalid_ballots_01`.`num_invalid_ballots`),
              0) AS `num invalid ballots from 0-1%`,
              ifnull(sum(`invalid_ballots_13`.`num_invalid_ballots`),
              0) AS `num invalid ballots from 1-3%`,
              ifnull(sum(`invalid_ballots_35`.`num_invalid_ballots`),
              0) AS `num invalid ballots from 3-5%`,
              ifnull(sum(`invalid_ballots_>5`.`num_invalid_ballots`),
              0) AS `num invalid ballots >5%`,
              (100 * (sum(`raw`.`num_valid_votes`) / sum(`raw`.`num_possible_voters`))) AS `percent voters voting`,
              sum(`raw`.`logic_check_fail`) AS `num precincts logic fail`,
              (100 * (sum(`raw`.`logic_check_fail`) / count(0))) AS `percent precincts logic fail`,
              (sum(`raw`.`logic_check_difference`) / sum(`raw`.`logic_check_fail`)) AS `avg precinct logic fail difference`,
              sum(`raw`.`more_ballots_than_votes_flag`) AS `num precincts more ballots than votes`,
              (100 * (sum(`raw`.`more_ballots_than_votes_flag`) / count(0))) AS `percent precincts more ballots than votes`,
              (sum(`raw`.`more_ballots_than_votes`) / sum(`raw`.`more_ballots_than_votes_flag`)) AS `avg precinct difference more ballots than votes`,
              sum(`raw`.`more_votes_than_ballots_flag`) AS `num precincts more votes than ballots`,
              (100 * (sum(`raw`.`more_votes_than_ballots_flag`) / count(0))) AS `percent precincts more votes than ballots`,
              (sum(`raw`.`more_votes_than_ballots`) / sum(`raw`.`more_votes_than_ballots_flag`)) AS `avg precinct difference more votes than ballots`,
              sum(`raw`.`num_at_12`) AS `votes 8-12`,
              sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) AS `votes 12-17`,
              sum((`raw`.`num_votes` - `raw`.`num_at_17`)) AS `votes 17-20`,
              (sum(`raw`.`num_at_12`) / count(0)) AS `avg votes/precinct 8-12`,
              (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / count(0)) AS `avg votes/precinct 12-17`,
              (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / count(0)) AS `avg votes/precinct 17-20`,
              (sum(`raw`.`num_at_12`) / 240) AS `vpm 8-12`,
              (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) AS `vpm 12-17`,
              (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 300) AS `vpm 17-20`,
              ((sum(`raw`.`num_at_12`) / 240) / count(0)) AS `avg vpm/precinct 8-12`,
              ((sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) / count(0)) AS `avg vpm/precinct 12-17`,
              ((sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 200) / count(0)) AS `avg vpm/precinct 17-20`,
              ifnull(sum(`vpm1`.`vpm > #{@@vpm_limit}`),
              0) AS `num precincts vpm 8-12 > #{@@vpm_limit}`,
              ifnull(sum(`vpm2`.`vpm > #{@@vpm_limit}`),
              0) AS `num precincts vpm 12-17 > #{@@vpm_limit}`,
              ifnull(sum(`vpm3`.`vpm > #{@@vpm_limit}`),
              0) AS `num precincts vpm 17-20 > #{@@vpm_limit}`,
              ((ifnull(sum(`vpm1`.`vpm > #{@@vpm_limit}`),
              0) + ifnull(sum(`vpm2`.`vpm > #{@@vpm_limit}`),
              0)) + ifnull(sum(`vpm3`.`vpm > #{@@vpm_limit}`),
              0)) AS `num precincts vpm > #{@@vpm_limit}`,
              `precinct_count`.`num_precincts` AS `num_precincts_possible`,
              count(`raw`.`precinct_id`) AS `num_precincts_reported_number`,
              ((100 * count(`raw`.`precinct_id`)) / `precinct_count`.`num_precincts`) AS `num_precincts_reported_percent`,
              "
      party_sql = []
      parties.each do |party|
        party_name = "#{party[:id]} - #{party[:name]}"
        party_sql << "sum(`raw`.`#{party_name}`) AS `#{party_name} count`,
                     (100 * (sum(`raw`.`#{party_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{party_name}`"
      end
      sql << party_sql.join(', ')

      sql << " from ((((((((`#{self.analysis_table_name} - raw` `raw`
              join `#{self.analysis_table_name} - precinct count by major district` `precinct_count` on((`raw`.`district_id` = `precinct_count`.`district_id`) and (`raw`.`major_district_id` = `precinct_count`.`major_district_id`)))
              left join `#{self.analysis_table_name} - vpm 8-12>#{@@vpm_limit}` `vpm1` on(((`raw`.`region` = `vpm1`.`region`) and (`raw`.`district_id` = `vpm1`.`district_id`) and(`raw`.`major_district_id` = `vpm1`.`major_district_id`) and (`raw`.`precinct_id` = `vpm1`.`precinct_id`))))
              left join `#{self.analysis_table_name} - vpm 12-17>#{@@vpm_limit}` `vpm2` on(((`raw`.`region` = `vpm2`.`region`) and (`raw`.`district_id` = `vpm2`.`district_id`) and (`raw`.`major_district_id` = `vpm2`.`major_district_id`) and (`raw`.`precinct_id` = `vpm2`.`precinct_id`))))
              left join `#{self.analysis_table_name} - vpm 17-20>#{@@vpm_limit}` `vpm3` on(((`raw`.`region` = convert(`vpm3`.`region` using utf8)) and (`raw`.`district_id` = `vpm3`.`district_id`) and (`raw`.`major_district_id` = `vpm3`.`major_district_id`) and (`raw`.`precinct_id` = `vpm3`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 0-1` `invalid_ballots_01` on(((`raw`.`region` = `invalid_ballots_01`.`region`) and (`raw`.`district_id` = `invalid_ballots_01`.`district_id`) and (`raw`.`major_district_id` = `invalid_ballots_01`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_01`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 1-3` `invalid_ballots_13` on(((`raw`.`region` = `invalid_ballots_13`.`region`) and (`raw`.`district_id` = `invalid_ballots_13`.`district_id` and (`raw`.`major_district_id` = `invalid_ballots_13`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_13`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 3-5` `invalid_ballots_35` on(((`raw`.`region` = `invalid_ballots_35`.`region`) and (`raw`.`district_id` = `invalid_ballots_35`.`district_id`) and (`raw`.`major_district_id` = `invalid_ballots_35`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_35`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots >5` `invalid_ballots_>5` on(((`raw`.`region` = `invalid_ballots_>5`.`region`) and (`raw`.`district_id` = `invalid_ballots_>5`.`district_id`) and (`raw`.`major_district_id` = `invalid_ballots_>5`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_>5`.`precinct_id`)))))
              where (`raw`.`district_id` not between 1 and 10)
              group by `raw`.`region`, `raw`.`district_name`, `raw`.`district_id`, `raw`.`major_district_id`"

      @@client.execute(sql)
    end
  end

  ################################################

  # run major tbilisi district view
  def run_major_tbilisi_districts(parties, delete_only=false)
    view_name = "#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}"
    @@client.execute("drop view if exists `#{view_name}`")
    if !delete_only
      sql = "create view `#{view_name}` as
              select `raw`.`region` AS `region`,
              `raw`.`district_id` AS `district_id`,
              `raw`.`district_name` AS `district_Name`,
              `raw`.`major_district_id` AS `major_district_id`,
              concat(cast(`raw`.`district_id` as char charset utf8),
              '-',
              cast(`raw`.`major_district_id` as char charset utf8)) AS `major_district_name`,
              sum(`raw`.`num_possible_voters`) AS `possible voters`,
              sum(`raw`.`num_votes`) AS `total ballots cast`,
              sum(`raw`.`num_valid_votes`) AS `total valid ballots cast`,
              ifnull(sum(`invalid_ballots_01`.`num_invalid_ballots`),
              0) AS `num invalid ballots from 0-1%`,
              ifnull(sum(`invalid_ballots_13`.`num_invalid_ballots`),
              0) AS `num invalid ballots from 1-3%`,
              ifnull(sum(`invalid_ballots_35`.`num_invalid_ballots`),
              0) AS `num invalid ballots from 3-5%`,
              ifnull(sum(`invalid_ballots_>5`.`num_invalid_ballots`),
              0) AS `num invalid ballots >5%`,
              (100 * (sum(`raw`.`num_valid_votes`) / sum(`raw`.`num_possible_voters`))) AS `percent voters voting`,
              sum(`raw`.`logic_check_fail`) AS `num precincts logic fail`,
              (100 * (sum(`raw`.`logic_check_fail`) / count(0))) AS `percent precincts logic fail`,
              (sum(`raw`.`logic_check_difference`) / sum(`raw`.`logic_check_fail`)) AS `avg precinct logic fail difference`,
              sum(`raw`.`more_ballots_than_votes_flag`) AS `num precincts more ballots than votes`,
              (100 * (sum(`raw`.`more_ballots_than_votes_flag`) / count(0))) AS `percent precincts more ballots than votes`,
              (sum(`raw`.`more_ballots_than_votes`) / sum(`raw`.`more_ballots_than_votes_flag`)) AS `avg precinct difference more ballots than votes`,
              sum(`raw`.`more_votes_than_ballots_flag`) AS `num precincts more votes than ballots`,
              (100 * (sum(`raw`.`more_votes_than_ballots_flag`) / count(0))) AS `percent precincts more votes than ballots`,
              (sum(`raw`.`more_votes_than_ballots`) / sum(`raw`.`more_votes_than_ballots_flag`)) AS `avg precinct difference more votes than ballots`,
              sum(`raw`.`num_at_12`) AS `votes 8-12`,
              sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) AS `votes 12-17`,
              sum((`raw`.`num_votes` - `raw`.`num_at_17`)) AS `votes 17-20`,
              (sum(`raw`.`num_at_12`) / count(0)) AS `avg votes/precinct 8-12`,
              (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / count(0)) AS `avg votes/precinct 12-17`,
              (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / count(0)) AS `avg votes/precinct 17-20`,
              (sum(`raw`.`num_at_12`) / 240) AS `vpm 8-12`,
              (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) AS `vpm 12-17`,
              (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 300) AS `vpm 17-20`,
              ((sum(`raw`.`num_at_12`) / 240) / count(0)) AS `avg vpm/precinct 8-12`,
              ((sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) / count(0)) AS `avg vpm/precinct 12-17`,
              ((sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 200) / count(0)) AS `avg vpm/precinct 17-20`,
              ifnull(sum(`vpm1`.`vpm > #{@@vpm_limit}`),
              0) AS `num precincts vpm 8-12 > #{@@vpm_limit}`,
              ifnull(sum(`vpm2`.`vpm > #{@@vpm_limit}`),
              0) AS `num precincts vpm 12-17 > #{@@vpm_limit}`,
              ifnull(sum(`vpm3`.`vpm > #{@@vpm_limit}`),
              0) AS `num precincts vpm 17-20 > #{@@vpm_limit}`,
              ((ifnull(sum(`vpm1`.`vpm > #{@@vpm_limit}`),
              0) + ifnull(sum(`vpm2`.`vpm > #{@@vpm_limit}`),
              0)) + ifnull(sum(`vpm3`.`vpm > #{@@vpm_limit}`),
              0)) AS `num precincts vpm > #{@@vpm_limit}`,
              `precinct_count`.`num_precincts` AS `num_precincts_possible`,
              count(`raw`.`precinct_id`) AS `num_precincts_reported_number`,
              ((100 * count(`raw`.`precinct_id`)) / `precinct_count`.`num_precincts`) AS `num_precincts_reported_percent`,
              "
      party_sql = []
      parties.each do |party|
        party_name = "#{party[:id]} - #{party[:name]}"
        party_sql << "sum(`raw`.`#{party_name}`) AS `#{party_name} count`,
                     (100 * (sum(`raw`.`#{party_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{party_name}`"
      end
      sql << party_sql.join(', ')

      sql << " from ((((((((`#{self.analysis_table_name} - raw` `raw`
              join `#{self.analysis_table_name} - precinct count by major district` `precinct_count` on((`raw`.`district_id` = `precinct_count`.`district_id`) and (`raw`.`major_district_id` = `precinct_count`.`major_district_id`)))
              left join `#{self.analysis_table_name} - vpm 8-12>#{@@vpm_limit}` `vpm1` on(((`raw`.`region` = `vpm1`.`region`) and (`raw`.`district_id` = `vpm1`.`district_id`) and(`raw`.`major_district_id` = `vpm1`.`major_district_id`) and (`raw`.`precinct_id` = `vpm1`.`precinct_id`))))
              left join `#{self.analysis_table_name} - vpm 12-17>#{@@vpm_limit}` `vpm2` on(((`raw`.`region` = `vpm2`.`region`) and (`raw`.`district_id` = `vpm2`.`district_id`) and (`raw`.`major_district_id` = `vpm2`.`major_district_id`) and (`raw`.`precinct_id` = `vpm2`.`precinct_id`))))
              left join `#{self.analysis_table_name} - vpm 17-20>#{@@vpm_limit}` `vpm3` on(((`raw`.`region` = convert(`vpm3`.`region` using utf8)) and (`raw`.`district_id` = `vpm3`.`district_id`) and (`raw`.`major_district_id` = `vpm3`.`major_district_id`) and (`raw`.`precinct_id` = `vpm3`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 0-1` `invalid_ballots_01` on(((`raw`.`region` = `invalid_ballots_01`.`region`) and (`raw`.`district_id` = `invalid_ballots_01`.`district_id`) and (`raw`.`major_district_id` = `invalid_ballots_01`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_01`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 1-3` `invalid_ballots_13` on(((`raw`.`region` = `invalid_ballots_13`.`region`) and (`raw`.`district_id` = `invalid_ballots_13`.`district_id` and (`raw`.`major_district_id` = `invalid_ballots_13`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_13`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots 3-5` `invalid_ballots_35` on(((`raw`.`region` = `invalid_ballots_35`.`region`) and (`raw`.`district_id` = `invalid_ballots_35`.`district_id`) and (`raw`.`major_district_id` = `invalid_ballots_35`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_35`.`precinct_id`))))
              left join `#{self.analysis_table_name} - invalid ballots >5` `invalid_ballots_>5` on(((`raw`.`region` = `invalid_ballots_>5`.`region`) and (`raw`.`district_id` = `invalid_ballots_>5`.`district_id`) and (`raw`.`major_district_id` = `invalid_ballots_>5`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_>5`.`precinct_id`)))))
              where (`raw`.`district_id` between 1 and 10)
              group by `raw`.`region`, `raw`.`district_name`, `raw`.`district_id`, `raw`.`major_district_id`"

      @@client.execute(sql)
    end
  end

  ################################################

  def create_csv_party_names(parties, shape)
    party_sql = []
    parties.each do |party|
      party_name = "#{party[:id]} - #{party[:name]}"
      party_sql << "`#{self.analysis_table_name} - #{shape}`.`#{party_name}` AS `#{party[:name]}`"
    end
    return party_sql.join(', ')
  end

  def run_csv(parties, delete_only=false)
    view_name = "#{self.analysis_table_name} - csv"
    @@client.execute("drop view if exists `#{view_name}`")
    if !delete_only
      sql = "create view `#{view_name}` as "

      # country
      sql << "(select 'Country' AS `#{@@common_headers[0]}`,
              'Georgia' AS `#{@@common_headers[1]}`,
              'Georgia' AS `#{@@common_headers[2]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`total valid ballots cast` AS `#{@@common_headers[3]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`percent voters voting` AS `#{@@common_headers[4]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`num invalid ballots from 0-1%` AS `#{@@common_headers[5]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`num invalid ballots from 1-3%` AS `#{@@common_headers[6]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`num invalid ballots from 3-5%` AS `#{@@common_headers[7]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`num invalid ballots >5%` AS `#{@@common_headers[8]}`,
              NULL AS `#{@@common_headers[9]}`,
              -- `#{self.analysis_table_name} - #{@@shapes[:country]}`.`num precincts logic fail` AS `#{@@common_headers[10]}`,
              -- `#{self.analysis_table_name} - #{@@shapes[:country]}`.`percent precincts logic fail` AS `#{@@common_headers[11]}`,
              -- `#{self.analysis_table_name} - #{@@shapes[:country]}`.`avg precinct logic fail difference` AS `#{@@common_headers[12]}`,
              -- NULL AS `#{@@common_headers[13]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`num precincts more ballots than votes` AS `#{@@common_headers[14]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`percent precincts more ballots than votes` AS `#{@@common_headers[15]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`avg precinct difference more ballots than votes` AS `#{@@common_headers[16]}`,
              NULL AS `#{@@common_headers[17]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`num precincts more votes than ballots` AS `#{@@common_headers[18]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`percent precincts more votes than ballots` AS `#{@@common_headers[19]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`avg precinct difference more votes than ballots` AS `#{@@common_headers[20]}`,
              NULL AS `#{@@common_headers[21]}`,
              NULL AS `#{@@common_headers[22]}`,
              NULL AS `#{@@common_headers[23]}`,
              NULL AS `#{@@common_headers[24]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`num precincts vpm 8-12 > #{@@vpm_limit}` AS `#{@@common_headers[25]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`num precincts vpm 12-17 > #{@@vpm_limit}` AS `#{@@common_headers[26]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`num precincts vpm 17-20 > #{@@vpm_limit}` AS `#{@@common_headers[27]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`num precincts vpm > #{@@vpm_limit}` AS `#{@@common_headers[28]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`num_precincts_reported_number` AS `#{@@common_headers[29]}`,
              `#{self.analysis_table_name} - #{@@shapes[:country]}`.`num_precincts_reported_percent` AS `#{@@common_headers[30]}`,
      "
      sql << create_csv_party_names(parties, @@shapes[:country])
      sql << " from `#{self.analysis_table_name} - #{@@shapes[:country]}`)"

      sql << " union "


      # region
      if self.has_regions
        sql << "(select 'Region' AS `#{@@common_headers[0]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`region` AS `#{@@common_headers[1]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`region` AS `#{@@common_headers[2]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`total valid ballots cast` AS `#{@@common_headers[3]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`percent voters voting` AS `#{@@common_headers[4]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`num invalid ballots from 0-1%` AS `#{@@common_headers[5]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`num invalid ballots from 1-3%` AS `#{@@common_headers[6]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`num invalid ballots from 3-5%` AS `#{@@common_headers[7]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`num invalid ballots >5%` AS `#{@@common_headers[8]}`,
                NULL AS `#{@@common_headers[9]}`,
                -- `#{self.analysis_table_name} - #{@@shapes[:region]}`.`num precincts logic fail` AS `#{@@common_headers[10]}`,
                -- `#{self.analysis_table_name} - #{@@shapes[:region]}`.`percent precincts logic fail` AS `#{@@common_headers[11]}`,
                -- `#{self.analysis_table_name} - #{@@shapes[:region]}`.`avg precinct logic fail difference` AS `#{@@common_headers[12]}`,
                -- NULL AS `#{@@common_headers[13]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`num precincts more ballots than votes` AS `#{@@common_headers[14]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`percent precincts more ballots than votes` AS `#{@@common_headers[15]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`avg precinct difference more ballots than votes` AS `#{@@common_headers[16]}`,
                NULL AS `#{@@common_headers[17]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`num precincts more votes than ballots` AS `#{@@common_headers[18]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`percent precincts more votes than ballots` AS `#{@@common_headers[19]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`avg precinct difference more votes than ballots` AS `#{@@common_headers[20]}`,
                NULL AS `#{@@common_headers[21]}`,
                NULL AS `#{@@common_headers[22]}`,
                NULL AS `#{@@common_headers[23]}`,
                NULL AS `#{@@common_headers[24]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`num precincts vpm 8-12 > #{@@vpm_limit}` AS `#{@@common_headers[25]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`num precincts vpm 12-17 > #{@@vpm_limit}` AS `#{@@common_headers[26]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`num precincts vpm 17-20 > #{@@vpm_limit}` AS `#{@@common_headers[27]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`num precincts vpm > #{@@vpm_limit}` AS `#{@@common_headers[28]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`num_precincts_reported_number` AS `#{@@common_headers[29]}`,
                `#{self.analysis_table_name} - #{@@shapes[:region]}`.`num_precincts_reported_percent` AS `#{@@common_headers[30]}`,
                "
        sql << create_csv_party_names(parties, @@shapes[:region])
        sql << " from `#{self.analysis_table_name} - #{@@shapes[:region]}`)"

        sql << " union "
      end

      # district
      sql << "(select 'District' AS `#{@@common_headers[0]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`district_id` AS `#{@@common_headers[1]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`district_Name` AS `#{@@common_headers[2]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`total valid ballots cast` AS `#{@@common_headers[3]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`percent voters voting` AS `#{@@common_headers[4]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`num invalid ballots from 0-1%` AS `#{@@common_headers[5]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`num invalid ballots from 1-3%` AS `#{@@common_headers[6]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`num invalid ballots from 3-5%` AS `#{@@common_headers[7]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`num invalid ballots >5%` AS `#{@@common_headers[8]}`,
            NULL AS `#{@@common_headers[9]}`,
            -- `#{self.analysis_table_name} - #{@@shapes[:district]}`.`num precincts logic fail` AS `#{@@common_headers[10]}`,
            -- `#{self.analysis_table_name} - #{@@shapes[:district]}`.`percent precincts logic fail` AS `#{@@common_headers[11]}`,
            -- `#{self.analysis_table_name} - #{@@shapes[:district]}`.`avg precinct logic fail difference` AS `#{@@common_headers[12]}`,
            -- NULL AS `#{@@common_headers[13]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`num precincts more ballots than votes` AS `#{@@common_headers[14]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`percent precincts more ballots than votes` AS `#{@@common_headers[15]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`avg precinct difference more ballots than votes` AS `#{@@common_headers[16]}`,
            NULL AS `#{@@common_headers[17]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`num precincts more votes than ballots` AS `#{@@common_headers[18]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`percent precincts more votes than ballots` AS `#{@@common_headers[19]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`avg precinct difference more votes than ballots` AS `#{@@common_headers[20]}`,
            NULL AS `#{@@common_headers[21]}`,
            NULL AS `#{@@common_headers[22]}`,
            NULL AS `#{@@common_headers[23]}`,
            NULL AS `#{@@common_headers[24]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`num precincts vpm 8-12 > #{@@vpm_limit}` AS `#{@@common_headers[25]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`num precincts vpm 12-17 > #{@@vpm_limit}` AS `#{@@common_headers[26]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`num precincts vpm 17-20 > #{@@vpm_limit}` AS `#{@@common_headers[27]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`num precincts vpm > #{@@vpm_limit}` AS `#{@@common_headers[28]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`num_precincts_reported_number` AS `#{@@common_headers[29]}`,
            `#{self.analysis_table_name} - #{@@shapes[:district]}`.`num_precincts_reported_percent` AS `#{@@common_headers[30]}`,
      "

      sql << create_csv_party_names(parties, @@shapes[:district])
      sql << " from `#{self.analysis_table_name} - #{@@shapes[:district]}`)"

      sql << " union "


      # major district
      if self.is_local_majoritarian

        sql << "(select 'Majoritarian District' AS `@@common_headers[0]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`major_district_id` AS `@@common_headers[1]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`major_district_Name` AS `@@common_headers[2]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`total valid ballots cast` AS `@@common_headers[3]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`percent voters voting` AS `@@common_headers[4]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`num invalid ballots from 0-1%` AS `@@common_headers[5]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`num invalid ballots from 1-3%` AS `@@common_headers[6]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`num invalid ballots from 3-5%` AS `@@common_headers[7]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`num invalid ballots >5%` AS `@@common_headers[8]`,
                NULL AS `@@common_headers[9]`,
                -- `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`num precincts logic fail` AS `@@common_headers[10]`,
                -- `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`percent precincts logic fail` AS `@@common_headers[11]`,
                -- `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`avg precinct logic fail difference` AS `@@common_headers[12]`,
                -- NULL AS `@@common_headers[13]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`num precincts more ballots than votes` AS `@@common_headers[14]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`percent precincts more ballots than votes` AS `@@common_headers[15]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`avg precinct difference more ballots than votes` AS `@@common_headers[16]`,
                NULL AS `@@common_headers[17]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`num precincts more votes than ballots` AS `@@common_headers[18]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`percent precincts more votes than ballots` AS `@@common_headers[19]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`avg precinct difference more votes than ballots` AS `@@common_headers[20]`,
                NULL AS `@@common_headers[21]`,
                NULL AS `@@common_headers[22]`,
                NULL AS `@@common_headers[23]`,
                NULL AS `@@common_headers[24]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`num precincts vpm 8-12 > #{@@vpm_limit}` AS `@@common_headers[25]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`num precincts vpm 12-17 > #{@@vpm_limit}` AS `@@common_headers[26]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`num precincts vpm 17-20 > #{@@vpm_limit}` AS `@@common_headers[27]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`num precincts vpm > #{@@vpm_limit}` AS `@@common_headers[28]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`num_precincts_reported_number` AS `@@common_headers[29]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_district]}`.`num_precincts_reported_percent` AS `@@common_headers[30]`,
        "
        sql << create_csv_party_names(parties, @@shapes[:major_district])
        sql << " from `#{self.analysis_table_name} - #{@@shapes[:major_district]}`)"

        sql << " union "

      end


      # precinct
      shape_prefix = ''
      name_prefix = ''
      if self.is_local_majoritarian == true
        shape_prefix = 'major_'
        name_prefix = 'Majoritarian '
      end
      shape = @@shapes[:"#{shape_prefix}precinct"]

      sql << "(select '#{name_prefix}Precinct' AS `#{@@common_headers[0]}`,
              `#{self.analysis_table_name} - #{shape}`.`precinct_id` AS `#{@@common_headers[1]}`,
              `#{self.analysis_table_name} - #{shape}`.`precinct_name` AS `#{@@common_headers[2]}`,
              `#{self.analysis_table_name} - #{shape}`.`total valid ballots cast` AS `#{@@common_headers[3]}`,
              `#{self.analysis_table_name} - #{shape}`.`percent voters voting` AS `#{@@common_headers[4]}`,
              NULL AS `#{@@common_headers[5]}`,
              NULL AS `#{@@common_headers[6]}`,
              NULL AS `#{@@common_headers[7]}`,
              NULL AS `#{@@common_headers[8]}`,
              `#{self.analysis_table_name} - #{shape}`.`percent invalid ballots` AS `#{@@common_headers[9]}`,
              -- NULL AS `#{@@common_headers[10]}`,
              -- NULL AS `#{@@common_headers[11]}`,
              -- NULL AS `#{@@common_headers[12]}`,
              -- `#{self.analysis_table_name} - #{shape}`.`logic_check_difference` AS `#{@@common_headers[13]}`,
              null AS `#{@@common_headers[14]}`,
              null AS `#{@@common_headers[15]}`,
              null AS `#{@@common_headers[16]}`,
              `#{self.analysis_table_name} - #{shape}`.`more_ballots_than_votes` AS `#{@@common_headers[17]}`,
              null AS `#{@@common_headers[18]}`,
              null AS `#{@@common_headers[19]}`,
              null AS `#{@@common_headers[20]}`,
              `#{self.analysis_table_name} - #{shape}`.`more_votes_than_ballots` AS `#{@@common_headers[21]}`,
              `#{self.analysis_table_name} - #{shape}`.`vpm 8-12` AS `#{@@common_headers[22]}`,
              `#{self.analysis_table_name} - #{shape}`.`vpm 12-17` AS `#{@@common_headers[23]}`,
              `#{self.analysis_table_name} - #{shape}`.`vpm 17-20` AS `#{@@common_headers[24]}`,
              NULL AS `#{@@common_headers[25]}`,
              NULL AS `#{@@common_headers[26]}`,
              NULL AS `#{@@common_headers[27]}`,
              NULL AS `#{@@common_headers[28]}`,
              NULL AS `#{@@common_headers[29]}`,
              NULL AS `#{@@common_headers[30]}`,
      "
      sql << create_csv_party_names(parties, shape)
      sql << " from `#{self.analysis_table_name} - #{shape}`)"

      sql << " union "


      # tbilisi district
      sql << "(select 'Tbilisi District' AS `#{@@common_headers[0]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`district_id` AS `#{@@common_headers[1]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`district_Name` AS `#{@@common_headers[2]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`total valid ballots cast` AS `#{@@common_headers[3]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`percent voters voting` AS `#{@@common_headers[4]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`num invalid ballots from 0-1%` AS `#{@@common_headers[5]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`num invalid ballots from 1-3%` AS `#{@@common_headers[6]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`num invalid ballots from 3-5%` AS `#{@@common_headers[7]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`num invalid ballots >5%` AS `#{@@common_headers[8]}`,
              NULL AS `#{@@common_headers[9]}`,
              -- `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`num precincts logic fail` AS `#{@@common_headers[10]}`,
              -- `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`percent precincts logic fail` AS `#{@@common_headers[11]}`,
              -- `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`avg precinct logic fail difference` AS `#{@@common_headers[12]}`,
              -- NULL AS `#{@@common_headers[13]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`num precincts more ballots than votes` AS `#{@@common_headers[14]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`percent precincts more ballots than votes` AS `#{@@common_headers[15]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`avg precinct difference more ballots than votes` AS `#{@@common_headers[16]}`,
              NULL AS `#{@@common_headers[17]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`num precincts more votes than ballots` AS `#{@@common_headers[18]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`percent precincts more votes than ballots` AS `#{@@common_headers[19]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`avg precinct difference more votes than ballots` AS `#{@@common_headers[20]}`,
              NULL AS `#{@@common_headers[21]}`,
              NULL AS `#{@@common_headers[22]}`,
              NULL AS `#{@@common_headers[23]}`,
              NULL AS `#{@@common_headers[24]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`num precincts vpm 8-12 > #{@@vpm_limit}` AS `#{@@common_headers[25]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`num precincts vpm 12-17 > #{@@vpm_limit}` AS `#{@@common_headers[26]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`num precincts vpm 17-20 > #{@@vpm_limit}` AS `#{@@common_headers[27]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`num precincts vpm > #{@@vpm_limit}` AS `#{@@common_headers[28]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`num_precincts_reported_number` AS `#{@@common_headers[29]}`,
              `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`.`num_precincts_reported_percent` AS `#{@@common_headers[30]}`,
      "
      sql << create_csv_party_names(parties, @@shapes[:tbilisi_district])
      sql << " from `#{self.analysis_table_name} - #{@@shapes[:tbilisi_district]}`)"

      sql << " union "


      # major tbilisi district
      if self.is_local_majoritarian
        sql << "(select 'Majoritarian Tbilisi District' AS `@@common_headers[0]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`major_district_id` AS `@@common_headers[1]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`major_district_Name` AS `@@common_headers[2]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`total valid ballots cast` AS `@@common_headers[3]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`percent voters voting` AS `@@common_headers[4]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`num invalid ballots from 0-1%` AS `@@common_headers[5]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`num invalid ballots from 1-3%` AS `@@common_headers[6]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`num invalid ballots from 3-5%` AS `@@common_headers[7]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`num invalid ballots >5%` AS `@@common_headers[8]`,
                NULL AS `@@common_headers[9]`,
                -- `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`num precincts logic fail` AS `@@common_headers[10]`,
                -- `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`percent precincts logic fail` AS `@@common_headers[11]`,
                -- `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`avg precinct logic fail difference` AS `@@common_headers[12]`,
                -- NULL AS `@@common_headers[13]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`num precincts more ballots than votes` AS `@@common_headers[14]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`percent precincts more ballots than votes` AS `@@common_headers[15]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`avg precinct difference more ballots than votes` AS `@@common_headers[16]`,
                NULL AS `@@common_headers[17]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`num precincts more votes than ballots` AS `@@common_headers[18]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`percent precincts more votes than ballots` AS `@@common_headers[19]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`avg precinct difference more votes than ballots` AS `@@common_headers[20]`,
                NULL AS `@@common_headers[21]`,
                NULL AS `@@common_headers[22]`,
                NULL AS `@@common_headers[23]`,
                NULL AS `@@common_headers[24]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`num precincts vpm 8-12 > #{@@vpm_limit}` AS `@@common_headers[25]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`num precincts vpm 12-17 > #{@@vpm_limit}` AS `@@common_headers[26]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`num precincts vpm 17-20 > #{@@vpm_limit}` AS `@@common_headers[27]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`num precincts vpm > #{@@vpm_limit}` AS `@@common_headers[28]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`num_precincts_reported_number` AS `@@common_headers[29]`,
                `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`.`num_precincts_reported_percent` AS `@@common_headers[30]`,
        "

        sql << create_csv_party_names(parties, @@shapes[:major_tbilisi_district])
        sql << " from `#{self.analysis_table_name} - #{@@shapes[:major_tbilisi_district]}`)"

        sql << " union "


      end

      # tbilisi precinct
      shape_prefix = ''
      name_prefix = ''
      if self.is_local_majoritarian == true
        shape_prefix = 'major_'
        name_prefix = 'Majoritarian '
      end
      shape = @@shapes[:"#{shape_prefix}tbilisi_precinct"]

      sql << "(select '#{name_prefix}Tbilisi Precinct' AS `#{@@common_headers[0]}`,
              `#{self.analysis_table_name} - #{shape}`.`precinct_id` AS `#{@@common_headers[1]}`,
              `#{self.analysis_table_name} - #{shape}`.`precinct_name` AS `#{@@common_headers[2]}`,
              `#{self.analysis_table_name} - #{shape}`.`total valid ballots cast` AS `#{@@common_headers[3]}`,
              `#{self.analysis_table_name} - #{shape}`.`percent voters voting` AS `#{@@common_headers[4]}`,
              NULL AS `#{@@common_headers[5]}`,
              NULL AS `#{@@common_headers[6]}`,
              NULL AS `#{@@common_headers[7]}`,
              NULL AS `#{@@common_headers[8]}`,
              `#{self.analysis_table_name} - #{shape}`.`percent invalid ballots` AS `#{@@common_headers[9]}`,
              -- NULL AS `#{@@common_headers[10]}`,
              -- NULL AS `#{@@common_headers[11]}`,
              -- NULL AS `#{@@common_headers[12]}`,
              -- `#{self.analysis_table_name} - #{shape}`.`logic_check_difference` AS `#{@@common_headers[13]}`,
              null AS `#{@@common_headers[14]}`,
              null AS `#{@@common_headers[15]}`,
              null AS `#{@@common_headers[16]}`,
              `#{self.analysis_table_name} - #{shape}`.`more_ballots_than_votes` AS `#{@@common_headers[17]}`,
              null AS `#{@@common_headers[18]}`,
              null AS `#{@@common_headers[19]}`,
              null AS `#{@@common_headers[20]}`,
              `#{self.analysis_table_name} - #{shape}`.`more_votes_than_ballots` AS `#{@@common_headers[21]}`,
              `#{self.analysis_table_name} - #{shape}`.`vpm 8-12` AS `#{@@common_headers[22]}`,
              `#{self.analysis_table_name} - #{shape}`.`vpm 12-17` AS `#{@@common_headers[23]}`,
              `#{self.analysis_table_name} - #{shape}`.`vpm 17-20` AS `#{@@common_headers[24]}`,
              NULL AS `#{@@common_headers[25]}`,
              NULL AS `#{@@common_headers[26]}`,
              NULL AS `#{@@common_headers[27]}`,
              NULL AS `#{@@common_headers[28]}`,
              NULL AS `#{@@common_headers[29]}`,
              NULL AS `#{@@common_headers[30]}`,
      "
      sql << create_csv_party_names(parties, shape)
      sql << " from `#{self.analysis_table_name} - #{shape}`)"


      @@client.execute(sql)
    end
  end

  #################################

  def run_precinct_counts(delete_only=false)
    puts "===================="
    puts '> creating precinct count tables/views'
    puts "===================="

    @@client.execute("drop table if exists `#{self.analysis_table_name} - precinct count`")
    if !delete_only
      sql = "CREATE TABLE `#{self.analysis_table_name} - precinct count` (
          `region` VARCHAR(255) NULL DEFAULT NULL,
          `district_id` INT(10) NOT NULL DEFAULT '0',"

      if self.is_local_majoritarian
        sql << "`major_district_id` INT(10) NOT NULL DEFAULT '0',"
      end

      sql << "`num_precincts` INT(11) NULL DEFAULT NULL,
          INDEX `region` (`region`),
          INDEX  `district` (`district_id`)"
      if self.is_local_majoritarian
        sql << ", INDEX `major_district_id` (`major_district_id`) "
      end
      sql << " )
        COLLATE='utf8_general_ci'
        ENGINE=MyISAM"
      @@client.execute(sql)
    end

    # total precincts
    @@client.execute("drop view if exists `#{self.analysis_table_name} - precinct count by #{@@shapes[:country]}`")
    if !delete_only
      @@client.execute("create view `#{self.analysis_table_name} - precinct count by #{@@shapes[:country]}` as
                  select sum(`num_precincts`) AS `num_precincts` from `#{self.analysis_table_name} - precinct count`")
    end

    # precincts by region
    @@client.execute("drop view if exists `#{self.analysis_table_name} - precinct count by #{@@shapes[:region]}`")
    if !delete_only
      @@client.execute("create view `#{self.analysis_table_name} - precinct count by #{@@shapes[:region]}` as
                    select `region` AS `region`,sum(`num_precincts`) AS `num_precincts` from `#{self.analysis_table_name} - precinct count` group by `region`")
    end

    # precincts by district
    if !delete_only
      @@client.execute("drop view if exists `#{self.analysis_table_name} - precinct count by #{@@shapes[:district]}`")
      @@client.execute("create view `#{self.analysis_table_name} - precinct count by #{@@shapes[:district]}` as
                    select `district_id` AS `district_id`,sum(`num_precincts`) AS `num_precincts` from `#{self.analysis_table_name} - precinct count` group by `district_id`")
    end

    if self.is_local_majoritarian || delete_only
      # precincts by major district
      @@client.execute("drop view if exists `#{self.analysis_table_name} - precinct count by major district`")
      if !delete_only
        @@client.execute("create view `#{self.analysis_table_name} - precinct count by major district` as
                    select `district_id` AS `district_id`,`major_district_id` AS `major_district_id`,sum(`num_precincts`) AS `num_precincts` from `#{self.analysis_table_name} - precinct count` group by `district_id`,`major_district_id`")
      end
    end
  end

end