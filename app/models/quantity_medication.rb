class QuantityMedication < ApplicationRecord
  validates :quantity, presence: true
  validates :medication, presence: true
  validates_associated :medication

  belongs_to :medication
  belongs_to :quantifiable, :polymorphic => true

  accepts_nested_attributes_for :medication

  #Métodos públicos
  def decrement
    self.medication.decrement(self.quantity)
  end
end
