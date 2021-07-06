class AddDeliveredByToInpatientPrescription < ActiveRecord::Migration[5.2]
  def change
    add_reference :inpatient_prescription_products, :delivered_by, index: true
  end
end
