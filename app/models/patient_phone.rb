class PatientPhone < ApplicationRecord
  enum phone_type: { Móvil: 1, Casa: 2, Trabajo: 3, fijo: 4, celular: 5 }

  belongs_to :patient

  validates_uniqueness_of :number, scope: [:patient_id]
end
