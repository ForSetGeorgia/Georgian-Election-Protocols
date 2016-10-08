class ElectionShapeFlag < ActiveRecord::Migration
  def change
    add_column :elections, :has_custom_shape_levels, :boolean, default: true
  end
end
