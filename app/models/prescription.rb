class Prescription < ApplicationRecord
  #belongs_to :id_professional
  #belongs_to :id_patient
  #belongs_to :id_prescription_status

  has_many :prescription_medications
  has_many :medications,
           :through => :prescription_medications

  accepts_nested_attributes_for :prescription_medications,
                                :reject_if => :all_blank,
                                :allow_destroy => :true
  accepts_nested_attributes_for :medications

end
