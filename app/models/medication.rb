class Medication < ApplicationRecord
  validates :vademecum, presence: true
  validates :expiration_date, presence: true
  validates :date_received, presence:true

  belongs_to :vademecum
  belongs_to :medication_brand
end
