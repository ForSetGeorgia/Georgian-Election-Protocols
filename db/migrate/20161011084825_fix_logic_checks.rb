class FixLogicChecks < ActiveRecord::Migration
  def up
    client = ActiveRecord::Base.connection
    now = Time.now

    # logic check values were not properly being saved cause the values were boolean and not integer
    elections = ['2016_parliamentary_party_list', '2016_parliamentary_majoritarian']

    elections.each do |election|
      puts election
      # logic check
      puts "- fixing logic check"
      sql = "update `protocol_analysis`.`#{election} - raw`
            set logic_check_fail = 1
            where logic_check_difference != 0"
      client.execute(sql)

      # ballots > votes
      puts "- fixing ballots > votes"
      sql = "update `protocol_analysis`.`#{election} - raw`
            set more_ballots_than_votes_flag = 1
            where more_ballots_than_votes != 0"
      client.execute(sql)

      # votes > ballots
      puts "- fixing votes > ballots"
      sql = "update `protocol_analysis`.`#{election} - raw`
            set more_votes_than_ballots_flag = 1
            where more_votes_than_ballots != 0"
      client.execute(sql)
    end
  end

  def down
    puts "do nothing"
  end
end
