class CreateLotProvenances < ActiveRecord::Migration[5.2]
  def change
    create_table :lot_provenances do |t|
      t.string :name

      t.timestamps
    end
    LotProvenance.create(name: 'Provincia')
  end
end
