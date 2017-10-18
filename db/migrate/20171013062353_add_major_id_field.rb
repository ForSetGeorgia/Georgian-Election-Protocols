class AddMajorIdField < ActiveRecord::Migration
  def change
    add_column :district_precincts, :major_district_id, :string, limit: 10
  end
end
