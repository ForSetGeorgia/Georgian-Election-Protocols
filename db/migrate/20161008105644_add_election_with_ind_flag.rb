class AddElectionWithIndFlag < ActiveRecord::Migration
  def change
    add_column :elections, :has_indepenedent_parties, :boolean, default: false
  end
end
