class ChangeColumnDniFromPatients < ActiveRecord::Migration[5.2]
  def change
    change_column :patients, :dni, :string
  end
end
