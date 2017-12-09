class QuantitySupply < ApplicationRecord
  belongs_to :supply
  belongs_to :quantifiable, :polymorphic => true
end
