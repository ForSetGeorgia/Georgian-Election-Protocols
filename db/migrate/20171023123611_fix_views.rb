class FixViews < ActiveRecord::Migration
  def up
    Election.can_enter.each do |election|
      election.create_analysis_views

      if election.is_local_majoritarian?
        # rebuild the precinct count table too
        election.create_precinct_count_tables_and_views
        election.create_analysis_precinct_counts
      end
    end
  end

  def down
    Election.can_enter.each do |election|
      election.create_analysis_views

      if election.is_local_majoritarian?
        # rebuild the precinct count table too
        election.create_precinct_count_tables_and_views
        election.create_analysis_precinct_counts
      end
    end
  end
end
