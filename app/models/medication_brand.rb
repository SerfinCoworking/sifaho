class MedicationBrand < ApplicationRecord
  validates :name, presence: true

  belongs_to :laboratory
  has_many :medication

  accepts_nested_attributes_for :laboratory

  def name_and_lab
    self.name<<" - "<<self.laboratory.name
  end
end
