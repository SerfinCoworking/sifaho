class DestroyInactiveProfessionalsWithoutPrescriptions < ActiveRecord::Migration[5.2]
  def change
    # Get all inactive professionals without prescriptions and destroy
    Professional.includes(:outpatient_prescriptions, :chronic_prescriptions)
                .where(is_active: false)
                .where(outpatient_prescriptions: { id: nil }, chronic_prescriptions: { id: nil })
                .find_each(&:destroy)
  end
end
