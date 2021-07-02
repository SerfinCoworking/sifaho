class AddStatusToOriginalChronicPrescriptionProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :original_chronic_prescription_products, :treatment_status, :integer, default: 0
  end
end
