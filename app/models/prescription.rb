class Prescription < ApplicationRecord
  belongs_to :id_professional
  belongs_to :id_patient
  belongs_to :id_prescription_status
end
