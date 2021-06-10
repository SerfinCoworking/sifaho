class CreateInpatientMovementTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :inpatient_movement_types do |t|
      t.string :name

      t.timestamps
    end
    InpatientMovementType.create(name: 'ingreso')
    InpatientMovementType.create(name: 'egreso')
    InpatientMovementType.create(name: 'traspaso')
  end
end
