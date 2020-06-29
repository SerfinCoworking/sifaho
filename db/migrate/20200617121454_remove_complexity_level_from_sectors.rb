class RemoveComplexityLevelFromSectors < ActiveRecord::Migration[5.2]
  def change
    remove_column :sectors, :complexity_level, :integer
  end
end
