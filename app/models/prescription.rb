class Prescription < ApplicationRecord
  belongs_to :professional
  belongs_to :patient
  #belongs_to :prescription_status

  has_many :quantity_medications, :as => :quantifiable
  has_many :medications, :through => :quantity_medications
  has_many :quantity_supplies, :as => :quantifiable
  has_many :supplies, :through => :quantity_supplies
end
