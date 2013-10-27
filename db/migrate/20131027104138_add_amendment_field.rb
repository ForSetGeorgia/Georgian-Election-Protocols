class AddAmendmentField < ActiveRecord::Migration
  def change
    add_column :district_precincts, :has_amendment, :boolean, :default => false
    add_index :district_precincts, :has_amendment
  end
end
