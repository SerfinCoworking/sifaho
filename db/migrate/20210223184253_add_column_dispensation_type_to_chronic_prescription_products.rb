class AddColumnDispensationTypeToChronicPrescriptionProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :chronic_prescription_products, :dispensation_type, index: true
  end
end
