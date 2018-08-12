class QuantityOrdSupplyLot < ApplicationRecord
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

  # Retorna el código del insumo del lote
  def supply_code
    self.supply_lot.code
  end

  def lot_code
    self.supply_lot.lot_code
  end

  # Retorna fecha de expiración del lote
  def expiry_date
    self.supply_lot.expiry_date
  end

  # Retorna el tipo de unidad
  def unity
    self.supply_lot.unity
  end
end
