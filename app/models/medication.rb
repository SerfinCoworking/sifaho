class Medication < ApplicationRecord
  validates :vademecum, presence: true
  validates :vademecum, presence: true
  validates :expiration_date, presence: true
  validates :date_received, presence:true

  belongs_to :vademecum
end
