class QuantityMedication < ApplicationRecord
  # Relaciones
  belongs_to :medication
  belongs_to :quantifiable, :polymorphic => true

  # Validaciones
  validates_presence_of :quantity
  validates_presence_of :medication
  validates_associated :medication

  accepts_nested_attributes_for :medication

  #Métodos públicos
  def decrement
    self.medication.decrement(self.quantity)
  end
end
