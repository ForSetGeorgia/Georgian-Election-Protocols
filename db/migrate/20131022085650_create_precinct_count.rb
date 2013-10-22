class CreatePrecinctCount < ActiveRecord::Migration
  def up

    create_table :president2013s_precinct_count do |t|
      t.string :region
      t.integer :district_id
      t.integer :num_precincts

      t.timestamps
    end
    
    add_index :president2013s_precinct_count, :district_id
    add_index :president2013s_precinct_count, :region
    
    execute "drop view if exists `president2013s_precinct_count_country`"
    execute "drop view if exists `president2013s_precinct_count_district`"
    execute "drop view if exists `president2013s_precinct_count_region`"
    
    
    execute "create view `president2013s_precinct_count_country` as select sum(`num_precincts`) AS `num_precincts` from `president2013s_precinct_count`"
    execute "create view `president2013s_precinct_count_district` as select `district_id` AS `district_id`,sum(`num_precincts`) AS `num_precincts` from `president2013s_precinct_count` group by `district_id`"
    execute "create view `president2013s_precinct_count_region` as select `region` AS `region`,sum(`num_precincts`) AS `num_precincts` from `president2013s_precinct_count` group by `region`"
  end
  

  def down
    remove_index :president2013s_precinct_count, :district_id
    remove_index :president2013s_precinct_count, :region
    drop_table :president2013s_precinct_count


    execute "drop view if exists `president2013s_precinct_count_country`"
    execute "drop view if exists `president2013s_precinct_count_district`"
    execute "drop view if exists `president2013s_precinct_count_region`"
  end
end
