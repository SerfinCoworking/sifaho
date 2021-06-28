class AddFaIconToInpatientMovementTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :inpatient_movement_types, :fa_icon, :string, default: 'exchange-alt'
  end
end
