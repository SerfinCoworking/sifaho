class CreateEstablishments < ActiveRecord::Migration[5.1]
  def change
    create_table :establishments do |t|
      t.string :code
      t.string :name
      t.string :cuit
      t.string :domicile
      t.string :phone
      t.string :email

      t.timestamps
    end
  end
end
