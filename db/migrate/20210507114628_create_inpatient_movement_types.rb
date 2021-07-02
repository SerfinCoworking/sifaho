class CreateInpatientMovementTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :inpatient_movement_types do |t|
      t.string :name
      t.string :fa_icon, default: 'exchange-alt'

      t.timestamps
    end
    InpatientMovementType.create(name: 'ingreso', fa_icon: 'sign-in-alt')
    InpatientMovementType.create(name: 'egreso', fa_icon: 'sign-out-alt')
    InpatientMovementType.create(name: 'traspaso', fa_icon: 'exchange-alt')
  end
end
