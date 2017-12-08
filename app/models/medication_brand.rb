class MedicationBrand < ApplicationRecord
  validates :name, presence: true

  belongs_to :laboratory
  has_many :medication
end
