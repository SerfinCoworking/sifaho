class PatientPhone < ApplicationRecord
  enum phone_type: { Móvil: 1, Casa: 2, Trabajo: 3 }

  belongs_to :patient

  validates_uniqueness_of :number, scope: [:patient_id]
end
