class AddSectorToPatientProductReport < ActiveRecord::Migration[5.2]
  def change
    add_reference :patient_product_reports, :sector, index: true
  end
end
