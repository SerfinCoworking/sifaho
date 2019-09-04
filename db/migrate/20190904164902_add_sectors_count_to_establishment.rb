class AddSectorsCountToEstablishment < ActiveRecord::Migration[5.2]
  def change
    add_column :establishments, :sectors_count, :integer, default: 0
  end
end
