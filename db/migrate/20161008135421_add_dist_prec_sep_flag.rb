class AddDistPrecSepFlag < ActiveRecord::Migration
  def change
    add_column :elections, :district_precinct_separator, :string, limit: 5, default: '-'
  end
end
