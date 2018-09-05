class ChangeColumnName < ActiveRecord::Migration[5.1]
  def change
    rename_column :sectors, :sector_name, :name
  end
end
