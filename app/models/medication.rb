class Medication < ApplicationRecord
  validates :vademecum, presence: true
  validates :expiry_date, presence: true
  validates :date_received, presence:true

  belongs_to :vademecum
  belongs_to :medication_brand

  has_many :quantity_medications
  has_many :prescriptions,
           :through => :quantity_medications,
           :source => :quantifiable,
           :source_type => 'Prescription'


end
