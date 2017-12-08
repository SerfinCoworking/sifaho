class Medication < ApplicationRecord  
  validates :vademecum, presence: true
  validates :expiry_date, presence: true
  validates :date_received, presence:true

  belongs_to :vademecum
  belongs_to :medication_brand

  has_many :prescription_medications
  has_many :prescriptions, through: :prescription_medications
end
