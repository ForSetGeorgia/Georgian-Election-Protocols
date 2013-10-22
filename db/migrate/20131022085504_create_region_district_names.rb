class CreateRegionDistrictNames < ActiveRecord::Migration
  def change
    create_table :region_district_names do |t|
      t.string :region
      t.integer :district_id
      t.string :district_name

      t.timestamps
    end
    
    add_index :region_district_names, :district_id
  end
end
