class QuantitySupplyRequest < ApplicationRecord
  # Relaciones
  belongs_to :supply
  belongs_to :quantifiable, :polymorphic => true

  # Validaciones
  validates_presence_of :supply
  validates_associated :supply

  accepts_nested_attributes_for :supply

  #Métodos públicos

  # Retorna el nombre del insumo
  def supply_name
    self.supply.name
  end

  # Retorna el tipo de unidad
  def unity
    self.supply.unity
  end

  def supply_code
    self.supply.id
  end
end
