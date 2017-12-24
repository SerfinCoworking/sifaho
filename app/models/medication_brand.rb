class MedicationBrand < ApplicationRecord
  validates :name, presence: true

  belongs_to :laboratory
  has_many :medication

  def name_and_lab
    self.name<<" - "<<self.laboratory.name
  end
end
