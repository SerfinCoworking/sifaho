class QuantitySupplyLot < ApplicationRecord
  # Relaciones
  belongs_to :supply_lot
  belongs_to :quantifiable, :polymorphic => true

  # Validaciones
  validates_presence_of :supply_lot
  validates_associated :supply_lot

  accepts_nested_attributes_for :supply_lot

  #Métodos públicos
  def decrement
    self.supply_lot.decrement(self.quantity)
  end
end
