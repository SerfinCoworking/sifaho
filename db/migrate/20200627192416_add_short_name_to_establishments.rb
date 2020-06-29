class AddShortNameToEstablishments < ActiveRecord::Migration[5.2]
  def change
    add_column :establishments, :short_name, :string
  end
end
