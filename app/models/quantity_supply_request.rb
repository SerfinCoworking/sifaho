class QuantitySupplyRequest < ApplicationRecord
  # Relaciones
  belongs_to :supply
  belongs_to :quantifiable, :polymorphic => true

  # Validaciones
  validates_presence_of :supply
  validates_associated :supply

  accepts_nested_attributes_for :supply

  #Métodos públicos

  def supply_name
    self.supply.supply_name
  end
end
