class MedicationBrand < ApplicationRecord
  # Relaciones
  belongs_to :laboratory
  has_many :medication

  # Validaciones
  validates_presence_of :name

  accepts_nested_attributes_for :laboratory

  def name_and_lab
    self.name+" - "+self.laboratory.name
  end
end
