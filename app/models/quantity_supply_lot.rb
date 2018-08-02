class QuantitySupplyLot < ApplicationRecord
  # Relaciones
  belongs_to :supply_lot, -> { with_deleted }
  belongs_to :quantifiable, :polymorphic => true

  # Validaciones
  validates_presence_of :supply_lot
  validates_associated :supply_lot

  accepts_nested_attributes_for :supply_lot

  #Métodos públicos
  def decrement
      self.supply_lot.decrement(self.quantity)
  end

  def supply_name
    self.supply_lot.supply_name
  end
end
