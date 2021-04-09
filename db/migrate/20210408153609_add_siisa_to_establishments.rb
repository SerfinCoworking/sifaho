class AddSiisaToEstablishments < ActiveRecord::Migration[5.2]
  def change
    add_column :establishments, :siisa, :string, default: '0000000000000'
  end
end
