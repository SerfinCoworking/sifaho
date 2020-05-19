class CreateEstablishments < ActiveRecord::Migration[5.1]
  def change
    create_table :establishments do |t|
      t.string :code
      t.string :name
      t.string :cuit
      t.string :domicile
      t.string :phone
      t.string :email
      t.integer :sectors_count, default: 0

      t.timestamps
    end
    add_reference :sectors, :establishment, foreign_key: true
  end
end
