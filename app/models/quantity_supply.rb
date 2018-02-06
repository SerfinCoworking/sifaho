class QuantitySupply < ApplicationRecord
  validates_associated :supply

  belongs_to :supply
  belongs_to :quantifiable, :polymorphic => true

  #Métodos públicos
  def decrement
    self.supply.decrement(self.quantity)
  end
end
