class AddTrainedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :trained, :string
  end
end
