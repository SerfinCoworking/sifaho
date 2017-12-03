class CreatePatientTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :patient_types do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
