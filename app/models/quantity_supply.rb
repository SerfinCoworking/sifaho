class QuantitySupply < ApplicationRecord
  validates :supply, presence: true
  validates_associated :supply

  belongs_to :supply
  belongs_to :quantifiable, :polymorphic => true

  accepts_nested_attributes_for :supply

  #Métodos públicos
  def decrement
    self.supply.decrement(self.quantity)
  end
end
