class Prescription < ApplicationRecord
  #belongs_to :id_professional
  #belongs_to :id_patient
  #belongs_to :id_prescription_status

  has_many :quantity_medications, :as => :quantifiable
  has_many :medications, :through => :quantity_medications
end
